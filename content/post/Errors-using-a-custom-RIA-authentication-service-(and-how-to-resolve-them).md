---
title: "Errors using a custom RIA authentication service (and how to resolve them)"
date: "2010-06-30T00:00:00.0000000"
author: "Mike Goatly"
---
If you've created your own authentication service for a
Silverlight RIA application\, you might encounter the following
scenarios:

1\) If you get the following errors:

- GetUser should have returned a single user
- Logout should have returned a single\, anonymous user

Then the chances are your implementation of GetDefaultUser is
returning null\.

2\) However\, if you get these:

- Load operation failed for query 'GetUser'\. Entity 'User : null'
cannot be added to cache because it doesn't have a valid
identity
- Load operation failed for query 'Logout'\. Entity 'User : null'
cannot be added to cache because it doesn't have a valid
identity

Then you're probably returning a user object that has a null
Name\.

Fixing either of these problems is pretty simple \- just make
sure you return a populated user from GetDefaultUser that has a
name of String\.Empty\. Although the property IsAnonymous will return
true if you set the name to null\, other parts of the framework in
the Silverlight client will blow up if you try this\, hence scenario
2\.

