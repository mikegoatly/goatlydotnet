---
title: "Problems programatically creating AppPool"
date: "2011-03-21T00:00:00.0000000"
author: "Mike Goatly"
---
I was creating an AppPool using the Microsoft\.Web\.Administration
assembly today and kept running into this in the Application event
log:

> The worker process failed to initialize correctly and therefore
> could not be started\. The data is the error\.
> 
> 

The only "helpful" code that was provided in the event data was
**57000780**\. Not great\, but it was at least
consistent\.

It turns out that the ManagedRuntimeVersion property of the
ApplicationPool object is case sensitive\, so setting it to
**V4\.0** just won't cut it \- it has to be
**v4\.0**\. Unfortunately it won't tell you that
something is wrong if you do set it to the wrong value \- it just
blows up when you first try to access an application that uses
it\.

Hope that saves someone else a few minutes\!

