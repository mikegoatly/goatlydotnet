---
title: "NotSupportedException when calling EndGetResponse in Silverlight"
date: "2011-03-18T00:00:00.0000000"
author: "Mike Goatly"
---
This one had me stumped for a little while today\. I was using a
WebRequest in a Silverlight 4 application to post some data to an
API endpoint\, and whenever I called EndGetResponse\, a
NotSupportedException was thrown\.

To help illustrate the problem\, here's a mock\-up of the
code:

``` csharp

using System;
using System.Net;
using System.Windows.Controls;

namespace SilverlightApplication1
{
    public partial class MainPage : UserControl
    {
        public MainPage()
        {
            InitializeComponent();

            var request = (HttpWebRequest)WebRequest.Create("http://myapi.com");
            request.Method = "POST";

            var myPostData = new byte[10];
            request.ContentLength = myPostData.Length;

            request.BeginGetRequestStream(
                a =>
                {
                    var stream = request.EndGetRequestStream(a);
                    stream.Write(myPostData, 0, myPostData.Length);
                    request.BeginGetResponse(this.GetResponse, request);
                },
                null);
        }

        private void GetResponse(IAsyncResult ar)
        {
            var request = (HttpWebRequest)ar.AsyncState;
            var response = request.EndGetResponse(ar);
            
            // Get data from the response stream, etc.
        }
    }
}
```
After a brief spell of head\-scratching\, I got to the root of the
problem: **the request stream wasn't being closed before the
call to EndGetResponse**\. This meant that as far as the
WebRequest was concerned\, it was still sending data to the server
when I tried to get the response\. A NotSupportedException is
probably not the most appropriate exception to be thrown in this
situation\, but there you go\.

The fix is simple \- either close the request stream or\, even
better\, put it in a using statement to make sure it gets closed
off\. So lines 22 and 23 become:

``` csharp

using (var stream = request.EndGetRequestStream(a))
{
    stream.Write(myPostData, 0, myPostData.Length);
}
```
As a side note\, I'm usually pretty strict about wrapping objects
that implement IDisposable in a using statement \- this is a good
reminder why that is\!

