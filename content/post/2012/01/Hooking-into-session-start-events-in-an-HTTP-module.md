---
title: "Hooking into session start events in an HTTP module"
date: "2012-01-25T00:00:00.0000000"
author: "Mike Goatly"
---
According to the MSDN documentation you can't handle Session Start events in an HTTP module\. The reason for this is because when you are initialising an HTTP module you hook into events associated to the HttpApplication class\, and HttpApplication doesn't expose any events relating to the starting of sessions\.

As a refresher\, the Init method will typically look like something like this:

``` csharp
public void Init(HttpApplication context)
{
    // Hook into the HttpApplication events you want to respond to
    context.BeginRequest += this.BeginRequest;
}
```
So it's not possible… right? Wrong\, but only if you don't mind a slightly dirty hack\.

*I should probably make the standard disclaimer for this sort of thing \- it works on my machine\! \-  There are no guarantees if it will work in your environment\, and would strongly recommend testing it fully\!*

The trick is getting access to the *SessionStateModule* in the Init method\, and hooking into the Start event from there\, like this:

``` csharp
public void Init(HttpApplication context)
{
    var module = context.Modules["Session"] as SessionStateModule;
    if (module != null)
    {
        module.Start += this.Session_Start;
    }
}

private void Session_Start(object sender, EventArgs e)
{
    // Respond to the session start event however you need
}
```
This works by relying on the fact that there's a module in the application's HttpModuleCollection called *Session \-* a fairly safe bet unless you're really messing with the httpModules definition in the \.NET Framework's web\.config file\. Note\, however\, it could break if a new version of the framework comes along and names the module differently\, but it hasn't changed in any of the framework versions that have been released to date\.

