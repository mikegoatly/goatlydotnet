---
title: "Good Uses for SQL Server 2005 Common Table Expressions (Part 0)"
date: "2008-01-10T00:00:00.0000000"
author: "Mike Goatly"
---
A significant portion of my time as a developer is taken up
looking into different approaches solving problems with newer
technologies\. Often it feels like I'm trying to understand the
solution to a problem I haven't yet defined\, but I accept this
because I look upon it as adding tools to my arsenal that I can
draw upon when an appropriate situation arises\.

One such solution I've been aware of for a while now is the new
Common Table Expressions \(CTEs\) feature and related Ranking and
Windowing functions in SQL Server 2005\, and I've recently found
myself stuck with problems that are these features solve nicely\.
Although there are traditional tricks that work as well\, usually
involving cursors\, Ranking and Windowing provide a very neat
solution\.

I'm going to break the different scenarios out into separate
blog entries\, though it could be a very short series as I only have
2 planned so far\. Naturally\, I'll add more as and when I encounter
them\.

#### CTEs? Ranking and Windowing? What's that all about?

Good question\! I don't intend on covering the basics here\, as
there are already a plethora of good articles out there that will
do that for you \- I want to give you some real world examples
instead\. If you want to find out more about CTEs\, Ranking and
Windowing\, here are some links for you:

- [Using Common Table Expressions](http://msdn2.microsoft.com/en-us/library/ms190766.aspx) \(MSDN\)
- [Using Ranking and Windowing Functions in SQL
Server 2005](http://sqljunkies.com/Article/4E65FA2D-F1FE-4C29-BF4F-543AB384AFBB.scuk) \(SQL Junkies\)

