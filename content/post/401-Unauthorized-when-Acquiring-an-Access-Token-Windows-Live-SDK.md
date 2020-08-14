---
title: "401 Unauthorized when Acquiring an Access Token: Windows Live SDK"
date: "2010-12-23T00:00:00.0000000"
author: "Mike Goatly"
---
Working with other people is hard\. Working with new SDK
documentation is even harder\, especially when it's wrong\.

If you're following the [Working with OAuth WRAP](http://msdn.microsoft.com/en-us/library/ff749624.aspx) Windows Live SDK
documentation and you get to the [Acquiring an Access Token](http://msdn.microsoft.com/en-us/library/ff750952.aspx) sample you'll
probably encounter a 401 unauthorized error when you try and read
the response from
*https://consent\.live\.com/AccessToken\.aspx*\. This is because
the POST data that the sample code gets you to build up is
incorrect\.

Instead of:

``` csharp

string postData = string.Format(
    "{0}?wrap_client_id={1}&wrap_client_secret={2}&wrap_callback={3}&
     wrap_verification_code={4}&idtype={5}",
    requestUrl,
    appSettings["wll_appid"],
    appSettings["wll_secret"],
    "http://www.fabrikam.com",
    verificationCode,
    "CID");
```
Use this:

``` csharp

string postData = string.Format(
    "wrap_client_id={0}&wrap_client_secret={1}&wrap_callback={2}&
     wrap_verification_code={3}&idtype={4}",
    appSettings["wll_appid"],
    appSettings["wll_secret"],
    "http://www.fabrikam.com",
    verificationCode,
    "CID");
```
For some reason the sample code was including the URL the
request was going to in the post data\, which confuses the server
into thinking that no **wrap\_client\_id** has been
posted\.

Hope that helps\.

