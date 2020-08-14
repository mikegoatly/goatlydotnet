---
title: "Using LiveDataScript"
date: "2012-10-13T12:50:47.0000000"
author: "Mike Goatly"
---
[LiveDataScript](http://www.goatly.net/downloads/livedatascript) is a little utility to generate SQL insert scripts from SQL Server databases\. I wrote it quite a few years ago\, but since it’s still fairly useful and the last place it was hosted has now gone the way of the Dodo\, I’ve re\-hosted it [here](http://www.goatly.net/downloads/livedatascript)\.

This post will cover the high\-level basics of using the application\.

## Getting started

After starting LiveDataScript you’ll be prompted to select the server to connect to:

![image](http://www.goatly.net/Media/Default/Windows-Live-Writer/Using-LiveDataScript_D665/image_9039348c-b48b-4540-9d5b-d9f2c4e24909.png)

As you can see\, you can use Windows authentication or SQL Server authentication to connect\, depending on which is most appropriate for your server\.

Once you’re connected you’ll be able to drill into the databases available on the server in the Server Explorer pane:

![image](http://www.goatly.net/Media/Default/Windows-Live-Writer/Using-LiveDataScript_D665/image_46e95ce8-5a02-4965-b9f8-4d671edc574b.png)

Double clicking on a table will open it up in a new window:

[![image](http://www.goatly.net/Media/Default/Windows-Live-Writer/Using-LiveDataScript_D665/image_thumb.png)](http://www.goatly.net/Media/Default/Windows-Live-Writer/Using-LiveDataScript_D665/image_7.png)

## Scripting data from a table

### Scripting all the data

You have a couple of options here:

1. Select a table in the Server Explorer and press the Script Tables button \(![image](http://www.goatly.net/Media/Default/Windows-Live-Writer/Using-LiveDataScript_D665/image_4068c484-ff2e-417e-8a4e-a42de9b23291.png)\)
1. Open a table by double\-clicking on it and press the Script Window Results button \(![image](http://www.goatly.net/Media/Default/Windows-Live-Writer/Using-LiveDataScript_D665/image_dcd7957b-8977-4e2e-bfb2-e8ab5ed91b40.png)\)

Note that each of the buttons has a little dropdown associated to it\, giving you a choice of where you want to script to\, either to a new window\, a file or to the clipboard:

![image](http://www.goatly.net/Media/Default/Windows-Live-Writer/Using-LiveDataScript_D665/image_9ff29d4a-e060-4d6a-83ae-db2f95211208.png)

### Scripting a subset of data

Again\, a couple of options:

1. Open a table and change the SELECT statement to include a “TOP x” statement\, e\.g\. SELECT TOP 100\. Click Refresh Results \(or press F5\) and then Script Window Results\.
1. Open a table and highlight the rows that you want to script out\, then press Script Selected Rows \(![image](http://www.goatly.net/Media/Default/Windows-Live-Writer/Using-LiveDataScript_D665/image_9ce12f32-944a-475c-acc2-7481bda5a57b.png)\)

### Selecting the columns to script

You can always change the columns that should be scripted out by altering the SELECT statement\, but there is an easier way using the “Script Column Filters” panel:

![image](http://www.goatly.net/Media/Default/Windows-Live-Writer/Using-LiveDataScript_D665/image_6499085d-74d1-448d-96f3-8c094a15051f.png)

By simply unselecting columns in this list and scripting the results\, you will remove those columns from the resulting output\.

## Summary

That pretty much covers the basics – I’ll write another post soon covering some of the more advanced ways that you can generate scripts\.

