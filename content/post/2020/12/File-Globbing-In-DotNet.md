---
title: "File Globbing in .NET" # Title of the blog post.
date: 2020-12-07T17:16:21Z # Date of post creation.
description: "Article description." # Description used for search engine.
featured: true # Sets if post is a featured post, making appear on the home page side bar.
draft: false # Sets whether to render this page. Draft of true will not be rendered.
toc: false # Controls if a table of contents should be generated for first-level links automatically.
# menu: main
#featureImage: "/images/path/file.jpg" # Sets featured image on blog post.
#thumbnail: "/images/path/thumbnail.png" # Sets thumbnail image appearing inside card on homepage.
#shareImage: "/images/path/share.png" # Designate a separate image for social media sharing.
codeMaxLines: 20 # Override global value for how many lines within a code block before auto-collapsing.
#codeLineNumbers: false # Override global value for showing of line numbers within code block.
#figurePositionShow: true # Override global value for showing the figure label.
categories:
  - Coding
tags:
  - Coding
  - .NET
  - C#
  - Globbing
---

If you've ever written entries in a `.gitignore` file, you've written a glob. They can be simple, e.g. `*.so` matching all files with the `so` file extension, or a more complex, e.g. `**/bar/*.cs` matching files with the `cs` extension in folders called `bar` anywhere in the search path.

This is *very* different to the simple wildcard patterns that you can apply to the usual .NET IO functions, which only allow for matching wildcards against filenames, e.g. `Directory.GetFiles(folder, "*.cs")`.

So what if you want to be able to use glob matching in .NET? Well you're in luck - as with most things these days, there's a package for that: [Microsoft.Extensions.FileSystemGlobbing](https://www.nuget.org/packages/Microsoft.Extensions.FileSystemGlobbing/).

Usage is really simple - if you want to find all `.cs` files anywhere under a `src` folder, you could use:

``` csharp
// Get a reference to the directory you want to search in
var folder = new DirectoryInfo("myfolder");

// Create and configure the FileSystemGlobbing Matcher
var matcher = new Matcher();
matcher.AddInclude("**/src/**/*.cs");

// Execute the matcher against the directory
var result = matcher.Execute(new DirectoryInfoWrapper(folder));

Console.WriteLine("Has matches: " + result.HasMatches);

foreach (var file in result.Files)
{
    Console.WriteLine("Matched: " + file.Path);
}
```

You always need to instruct the `Matcher` what files to include, but you can be very broad with it and include everything 
under every subfolder with. `**/*`. You than then *filter out* files you're not interested in using `AddExclude`, 
or `AddExcludePatterns` if you want to exclude a list of patterns. 

A `.gitignore` is actually a list of patterns to exclude, so you could use the contents of a `.gitignore` file to find only the files that 
git would include by using:

``` csharp
var gitIgnoreGlobs = await File.ReadAllLinesAsync(".gitignore");

// Create and configure the FileSystemGlobbing Matcher using the ignore globs
var matcher = new Matcher();
matcher.AddInclude("**/*");
matcher.AddExcludePatterns(gitIgnoreGlobs);
```

If you want to apply different match rules to a set of files, you might want to avoid hitting the file system on each execution. Here you can use the in-memory APIs that FileSystemGlobbing exposes, by pre-reading the files to process and calling the `Match` function, instead of `Execute`:

``` csharp
var directory = new DirectoryInfo("myfolder");

// Pre-fetch the files recursively (The Match API needs the file paths as strings)
var files = directory.GetFiles("*", SearchOption.AllDirectories)
    .Select(f => f.FullName);

// Create the matcher using the rules you need
var matcher = new Matcher();

// Execute the matcher against the file list, specifying the root
// directory that the files were collected from so that the relative paths
// are correctly interpreted 
var result = matcher.Match(folder.FullName, files);
```