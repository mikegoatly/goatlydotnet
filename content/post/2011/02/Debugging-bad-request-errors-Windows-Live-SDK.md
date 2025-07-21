---
title: "Debugging bad request errors-Windows Live SDK"
date: "2011-02-02T00:00:00.0000000"
author: "Mike Goatly"
---
*Important note \- this code is **not** to be
considered production quality \- as always feel free to use it\, but
please take it with a handful of salt\. In my experience working
with these sorts of APIs can be a real killer if you're not
extremely careful about how you write your code\.*

When you're making calls to the live\.com endpoints from \.NET
code\, you'll probably be doing something like this:

``` csharp

var address = "https://consent.live.com/AccessToken.aspx";
var postData = String.Format(
    "wrap_client_id={0}&wrap_client_secret={1}&wrap_callback={2}&wrap_verification_code={3}&idtype={4}",
    myApiKey,
    clientSecret,
    callBackUrl,
    verificationCode,
    "CID");

// Create the request
var request = (HttpWebRequest)WebRequest.Create(address);
request.Method = "POST";
request.ContentType = "application/x-www-form-urlencoded";

// Post the data
var content = Encoding.UTF8.GetBytes(formData);
request.ContentLength = content.Length;
using (var requestStream = request.GetRequestStream())
{
    requestStream.Write(content, 0, content.Length);
}

// Read the response
var response = request.GetResponse();
if (response != null)
{
    using (var responseStream = response.GetResponseStream())
    {
        if (responseStream != null)
        {
            using (var reader = new StreamReader(responseStream))
            {
            // Read the response text and do something with it
                var responseText = reader.ReadToEnd();
            }
        }
    }
}
```
However if you've done anything wrong\, e\.g constructed the
request data incorrectly\, a 4xx response code will be returned \(400
bad request\, 401 unauthorized\, etc\) and when you call
request\.GetResponse\(\) a WebException will be thrown\.

In order to give yourself a fighting chance of debugging this\,
you'll need to catch the error and have a look in the response
stream \- you'll often find that you're being given more information
than you thought:

``` csharp

catch (WebException ex)
{
    using (var responseStream = ex.Response.GetResponseStream())
    {
        if (responseStream != null)
        {
            var responseData = new StreamReader(responseStream).ReadToEnd();
            
            // The response data from the live API services is formatted as
            // name=value&name2=value2, so we can use the HttpUtility to parse it
            var responseParameters = HttpUtility.ParseQueryString(responseData);
            var response = String.Join(
                "\r\n", 
                (from k in responseParameters.Keys.OfType<string>() 
                select k + ":" + responseParameters[k]).ToArray());

            // You'll probably want to create your own exception type!
            throw new Exception(response, ex);
        }
    }

    // Couldn't get the response, so just throw the previous exception
    throw ex;
}
```
Now instead of just getting an exception with an unhelpful
message\, you will *hopefully* get something that describes
the problem in a bit more detail\.

Hope this helps\.

