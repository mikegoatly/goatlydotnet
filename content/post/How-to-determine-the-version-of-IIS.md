---
title: "How to determine the version of IIS"
date: "2009-03-09T00:00:00.0000000"
author: "Mike Goatly"
---
It took me far too long to work this out; I needed to know
whether or not it was safe to try and set the ManagedPipelineMode
property on an AppPool\, and I figured the best way to do it would
be to check the current IIS version and if it was 7\.0 or above\. The
code to get the current version is straightforward\, once you know
the names of the properties to read:

``` csharp

DirectoryEntry iisVersionCheck = 
    new DirectoryEntry("IIS://localhost/W3SVC/Info");

int majorVersion = (int)iisVersionCheck.InvokeGet(
    "MajorIIsVersionNumber");

int minorVersion = (int)iisVersionCheck.InvokeGet(
    "MinorIIsVersionNumber");
```
