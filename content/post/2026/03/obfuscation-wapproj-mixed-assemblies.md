---
title: "Obfuscated assemblies and MSIX packaging: the mixed-build trap"
date: 2026-03-26
description: "How a .wapproj packaging project can silently mix obfuscated and un-obfuscated assemblies, causing cryptic crashes at startup"
draft: false
toc: false
codeMaxLines: 100
categories:
  - Coding
  - Windows
tags:
  - C#
  - .NET
  - Obfuscation
  - MSIX
  - Windows Store
  - Obfuscar
---

If you're packaging a .NET desktop app for the Windows Store using a WAP (Windows Application Packaging) project, and you're also running an obfuscator as a post-build step, there's a subtle trap waiting for you. The app works perfectly when you run the desktop `.exe` directly — but the packaged version crashes immediately on startup with a cryptic native exception.

This post walks through what's going wrong, how to confirm it with ILSpy, and how to fix it with a small addition to your `.wapproj`.

## The setup

Imagine a Contoso app with this project structure:

```
Contoso.Core          (class library, net10.0)
Contoso.Core.Services (class library, net10.0)
Contoso.ViewModels    (class library, net10.0)
Contoso.UI            (class library, net10.0, Avalonia/WPF UI)
Contoso.Desktop       (WinExe, net10.0-windows10.0.19041.0, entry point)
Contoso.WindowsStore  (.wapproj, packaging project)
```

`Contoso.Desktop` has a post-build obfuscation step using [Obfuscar](https://github.com/obfuscar/obfuscar). After building, the obfuscator rewrites all the Contoso assemblies in the Desktop output directory and copies them back in place, so the `bin\Release\...\` folder contains the obfuscated versions.

The `.wapproj` references `Contoso.Desktop.csproj` as its entry point project and packages everything up into an MSIX.

Running `Contoso.Desktop.exe` directly: works fine. Deploying and running via the `.wapproj` package: immediate crash.

## The error

The crash can show up as a `TypeLoadException` or `MissingMethodException`, and I've even see it as a native unhandled exception:

```
Unhandled exception at 0x... (KernelBase.dll): 0xE0434352
(parameters: 0xFFFFFFFF80131534, ...)
```

## What's going wrong

The key is understanding where the `.wapproj` DesktopBridge targets source their assemblies from.

When MSBuild builds the packaging project, it collects the binaries for the AppX layout by pulling each referenced project's output from that project's own `bin\` folder — **not** from the entry point project's output folder. So for our Contoso example:

- `Contoso.Core.dll` → sourced from `Contoso.Core\bin\Debug\net10.0\`
- `Contoso.Core.Services.dll` → sourced from `Contoso.Core.Services\bin\Debug\net10.0\`
- `Contoso.ViewModels.dll` → sourced from `Contoso.ViewModels\bin\Debug\net10.0\`
- `Contoso.UI.dll` → sourced from `Contoso.UI\bin\Debug\net10.0\`
- `Contoso.Desktop.exe` / `Contoso.Desktop.dll` → sourced from `Contoso.Desktop\bin\...\`

Those first four are **un-obfuscated** — they come straight from each library project's own output. The obfuscation step runs in `Contoso.Desktop` and writes obfuscated assemblies back to the Desktop output folder, but the DesktopBridge targets never look there for the library DLLs.

There's a second wrinkle for the entry point itself. You might assume that because `Contoso.Desktop` is the project running the obfuscator, its own output would be picked up correctly. But the WAP project doesn't source it from `bin\` — it queries the project's build outputs directly, which can pull the assembly from the intermediate `obj\` folder, before the post-build obfuscation step has touched it.

The result: the AppX layout contains a mix of obfuscated and un-obfuscated assemblies. The library DLLs come from their individual un-obfuscated `bin\` outputs. The entry point may come from `obj\` before obfuscation ran. None of them match. The runtime fails to find types or methods, and the app crashes.

When you run `Contoso.Desktop.exe` directly, you're running from the Desktop project's `bin\` output folder where obfuscation has already run over everything consistently — so there's no mismatch.

## Verifying it with ILSpy

Before fixing anything, it's worth confirming the mismatch is actually there. [ILSpy](https://github.com/icsharpcode/ILSpy) (or `ilspycmd` on the command line) can decompile the assemblies and show you whether obfuscation has been applied.

Open the AppX output folder for your packaging project — typically something like:

```
Contoso.WindowsStore\bin\x64\Release\AppX\Contoso.Desktop\
```

Open `Contoso.Core.dll` in ILSpy. If the assembly is un-obfuscated, you'll see your original type names in the tree:

```
Contoso.Core
  └─ Contoso.Core.Services
       └─ ILicensingService
       └─ LicensingService
       ...
```

Now open `Contoso.Desktop.dll` from the same folder and look at the IL for a method that calls into `Contoso.Core`. If obfuscation ran correctly on the entry point, you'll see it referencing scrambled names like `A.b::C()` — names that don't exist in the un-obfuscated `Contoso.Core.dll` sitting next to it.

That mismatch is exactly what causes the crash.

## The fix

The obvious approach — copying the obfuscated files into the AppX output folder after build — doesn't fully work. It fixes F5 deployment in Visual Studio, which registers the loose `AppX\` directory directly. But when you run "Create App Packages" to produce a final `.msix`, the packaging tool doesn't use the files on disk in that folder. It uses a recipe file (`.build.appxrecipe`) that MSBuild generates, containing the **original source paths** pointing back to each project's own `bin\` or `obj\` directory. The on-disk copy is bypassed entirely.

The right fix is to intercept the assembly list further upstream in the MSBuild pipeline, before it branches out into the various payload item groups and recipe files. The hook point is `BeforeTargets="_ConvertItems"` — this is where `CreateWapProjPackageFiles` runs to produce `WapProjPackageFile` and `UploadWapProjPackageFile`, which then feed everything downstream: the standard payload, the upload payload, and both recipe files. Redirect here and everything is covered in one place.

The item list at this stage is `_FilteredNonWapProjProjectOutput`. Each item's Identity is the source file path. Replacing the Identity redirects where the file is sourced from.

Add this to your `.wapproj`, after the `<Import Project="$(WapProjPath)\Microsoft.DesktopBridge.targets" />` line:

```xml
<!--
  The DesktopBridge targets source assemblies from each project's individual bin/ output
  (or obj/ for the entry point), which contain un-obfuscated binaries. Obfuscation runs as
  a post-build step in the Desktop project and writes obfuscated assemblies back to the
  Desktop TargetDir only. This target intercepts _FilteredNonWapProjProjectOutput before
  _ConvertItems runs, redirecting all obfuscated assemblies to the Desktop output directory.
  This covers F5 deployment, loose .msix packaging, and "Create App Packages" in one place.
-->
<Target Name="UseObfuscatedAssemblies" BeforeTargets="_ConvertItems" Condition="'$(SkipObfuscation)' != 'true'">
  <PropertyGroup>
    <_DesktopRid Condition="'$(Platform)' == 'x86'">win-x86</_DesktopRid>
    <_DesktopRid Condition="'$(Platform)' == 'x64'">win-x64</_DesktopRid>
    <_DesktopRid Condition="'$(Platform)' == 'ARM64'">win-arm64</_DesktopRid>
    <_DesktopOutputDir>$(MSBuildProjectDirectory)\..\Contoso.Desktop\bin\$(Platform)\$(Configuration)\net10.0-windows10.0.19041.0\$(_DesktopRid)\</_DesktopOutputDir>
    <!-- Semicolon-delimited list of assembly filenames (without extension) to redirect -->
    <_ObfuscationList>;Contoso;Contoso.Core;Contoso.Core.Services;Contoso.ViewModels;Contoso.UI;Contoso.Resources;</_ObfuscationList>
  </PropertyGroup>
  <ItemGroup>
    <_AssembliesToRedirect Include="@(_FilteredNonWapProjProjectOutput)"
                           Condition="$(_ObfuscationList.Contains(';%(Filename);'))" />
    <_FilteredNonWapProjProjectOutput Remove="@(_AssembliesToRedirect)" />
    <!-- The -> transform preserves all metadata (including TargetPath) from the original items -->
    <_FilteredNonWapProjProjectOutput Include="@(_AssembliesToRedirect->'$(_DesktopOutputDir)%(Filename)%(Extension)')" />
  </ItemGroup>
</Target>
```

A few things worth noting:

- `Contoso` in `_ObfuscationList` is the entry point assembly — the one built by `Contoso.Desktop.csproj`. It's included here because the WAP project may source it from `obj\` rather than `bin\`, bypassing the obfuscation step.
- The `_DesktopOutputDir` path includes the TFM segment (`net10.0-windows10.0.19041.0`) and RID. If you change the target framework or minimum Windows SDK version in your Desktop project, update this path to match.
- The `bin\$(Platform)\$(Configuration)\` structure assumes the Desktop project's `OutputPath` is configured to include the platform — typical for projects paired with a WAP project, but not the .NET SDK default. The RID subdirectory also only appears for self-contained builds. Adjust both to match your actual output layout.
- The `->` transform operator preserves all metadata from the original items, including `TargetPath` (the package-relative destination path). No explicit metadata assignment is needed.
- The `Condition="'$(SkipObfuscation)' != 'true'"` guard disables the redirect for debug configurations where obfuscation isn't running.

## Verifying it's fixed

Build and deploy again, then open the AppX output folder in ILSpy. Every Contoso assembly — including the entry point — should now show scrambled type names. The obfuscation is consistent across the whole package.

It's a frustrating problem to diagnose because the mismatch is completely invisible from the build output and only manifests as a crash at runtime, and only in the packaged context. But once you know where in the MSBuild pipeline to intercept, the fix is clean and covers all packaging paths in one target.
