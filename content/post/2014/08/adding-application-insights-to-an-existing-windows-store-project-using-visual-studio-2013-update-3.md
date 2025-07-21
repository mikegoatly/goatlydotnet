---
title: "Adding Application Insights to an existing Windows Store project using Visual Studio 2013 Update 3"
date: "2014-08-07T11:55:08.0000000"
author: "Mike Goatly"
tags:
- "Application Insights"
- "WinRT"
- "Visual Studio"
---
As of Update 3\, Visual Studio 2013 now has support for Application Insights built in\, so I thought I’d have a play with it again\.

Right now\, my primary focus is adding instrumentation to a [Windows 8 Store app I’m working on](http://www.chordle.com)\. I’d tried to do it with the previous Application Insights release \(which was in preview\)\, but found the need to explicitly build the app for all the various CPU targets a burden I could do without\. The release that comes with Update 3 would seem to have fixed this\, by allowing you to target Any CPU\.

This is a summary of my experience of adding Application Insights to my existing real\-world project\.

First I removed any indication that I had ever had Application Insights added to the store project by removing the ApplicationInsights\.config file that was already there from earlier attempts\.

Then I right\-clicked on the project\, and selected Add Application Insights – on doing this\, I received the following error:

> Could not add Application Insights to project\.  
> 
> Failed to install package: 
> 
> Microsoft\.ApplicationInsights\.WindowsStore 
> 
> with error: 
> 
> An error occurred while applying transformation to 'App\.xaml' in project '<PROJECT>: No element in the source document matches '/\_defaultNamespace:Application/\_defaultNamespace:Application\.Resources'
> 
> 

It turns out that the installer didn’t like the fact that my application had an unexpected App\.xaml structure\, due to the use of Prism as the application framework:

``` xml
<prism:MvvmAppBase x:Class="Chordle.UI.App"
                   xmlns=http://schemas.microsoft.com/winfx/2006/xaml/presentation
                   xmlns:x=http://schemas.microsoft.com/winfx/2006/xaml
                   xmlns:prism="using:Microsoft.Practices.Prism.StoreApps">
    <prism:MvvmAppBase.Resources>
        <ResourceDictionary>
…
        </ResourceDictionary>
    </prism:MvvmAppBase.Resources>
</prism:MvvmAppBase>
```
So to get around this\, I had to comment out my existing XAML and add in a temporary Application\.Resources area\, like this:

``` xml
<!--<prism:MvvmAppBase x:Class="Chordle.UI.App"
                   xmlns=http://schemas.microsoft.com/winfx/2006/xaml/presentation
                   xmlns:x=http://schemas.microsoft.com/winfx/2006/xaml
                   xmlns:prism="using:Microsoft.Practices.Prism.StoreApps">
    <prism:MvvmAppBase.Resources>
        <ResourceDictionary>
…
        </ResourceDictionary>
    </prism:MvvmAppBase.Resources>
</prism:MvvmAppBase>—->

<xaml:Application xmlns:xaml="http://schemas.microsoft.com/winfx/2006/xaml/presentation">
    <xaml:Application.Resources />
</xaml:Application>
```
And after closing App\.xaml\, I tried to add App Insights again\, this time it succeeded\, but I obviously had to fix\-up the App\.xaml file by uncommenting the original XAML\, and moving the new ai:TelemetryContext resource into my own resource dictionary structure\.

After all this\, I finally discovered that currently you can’t yet view Windows Store/Phone telemetry in the preview Azure Portal\, which is where the telemetry is going now\, so there’s no way for me to test our whether this has actually worked… I’ll write another post when I’ve got more to add\!

