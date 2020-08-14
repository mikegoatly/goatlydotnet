---
title: "Fixing NuGet errors after removing Microsoft.Bcl.Build"
date: "2014-08-05T20:20:36.0000000"
author: "Mike Goatly"
---
I found that a solution of mine was still referencing the Microsoft\.Bcl\.Build nuget project\, and as I was using Visual Studio 2013\, I figured it was no longer needed\, so I removed it\. After doing this\, some of the projects refused to compile\, reporting the error:

> This project references NuGet package\(s\) that are missing on this computer\. Enable NuGet Package Restore to download them\.  For more information\, see [http://go\.microsoft\.com/fwlink/?LinkID=317567](http://go.microsoft.com/fwlink/?LinkID=317567)\.
> 
> 

After I remembered that this package modifies the project files a little\, I fixed the broken projects by:

- Unloading them  
- Editing them\, removing the following lines:

```
<Import Project="..\packages\Microsoft.Bcl.Build.1.0.13\tools\Microsoft.Bcl.Build.targets" 
          Condition="Exists('…" />
<Target Name="EnsureBclBuildImported" BeforeTargets="BeforeBuild" Condition="…">
   <Error Condition="!Exists('…’)"
          Text="…" HelpKeyword="BCLBUILD2001" />
   <Error Condition="Exists('…)" 
          Text="…" HelpKeyword="BCLBUILD2002" />
</Target>
```
- Reloading them

 

Hope this helps someone else\.

