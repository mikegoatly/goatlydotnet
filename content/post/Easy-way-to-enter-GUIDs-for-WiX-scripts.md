---
title: "Easy way to enter GUIDs for WiX scripts"
date: "2006-07-20T00:00:00.0000000"
author: "Mike Goatly"
---
One of the pains of using WiX is that every component you
create has to have its own unique GUID\.Using the Tools/Create GUID\.\.\. option from Visual Studio is
one way to create a new GUID\, but you have to copy and paste it
into the right place in your script\, which\, when you have to create
in the region of a trillion components\, can be quite
tiresome\.The easiest way I've found of doing it is to create a custom
macro\, along the lines of:Sub Guid\(\) 
 DTE\.ActiveDocument\.Selection\.Text =System\.Guid\.NewGuid\.ToString
 End SubYou can then associate the macro to a keyboard shortcut
\(Tools/Options\.\.\./Keyboard\)\, e\.g\. Ctrl\-K\,Ctrl\-G\.

Creating a new GUIDs is then just two keystrokes away\. \(Or one
if you've configured a better alternative\!\)

