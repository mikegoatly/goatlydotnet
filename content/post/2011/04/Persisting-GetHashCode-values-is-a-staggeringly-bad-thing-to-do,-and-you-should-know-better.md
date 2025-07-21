---
title: "Persisting GetHashCode values is a staggeringly bad thing to do, and you should know better"
date: "2011-04-04T00:00:00.0000000"
author: "Mike Goatly"
---
The title pretty much sums up my feelings on the subject\, but it
probably needs a bit of context\.

I've been doing some work for a client that relies on a 3rd
party application framework \(No\, I'm not going to name and shame
the framework\!\)\. The application is split across multiple servers
and we've been upgrading some of them to a 64bit environment\. Once
we had completed the upgrade process\, other parts of the
application\, *on other servers*\, started breaking\.

After reflecting on the code a little\, I noticed that the code
running on the new 64bit server was storing a hash value in a
centralised database\. All the other servers were try to validate
themselves against this hash and failing\.

Now there's nothing particularly wrong in this approach\, the
problem comes about with the method of generating the hash:
String\.GetHashCode\.

From the MSDN documentation \(emphasis mine\):

> The default implementation of the GetHashCode method does not
> guarantee unique return values for different objects\. Furthermore\,
> the \.NET Framework **does not guarantee** the default
> implementation of the GetHashCode method\, and **the value it
> returns will be the same between different versions of the \.NET
> Framework**\. Consequently\, the default implementation of
> this method must not be used as a unique object identifier for
> hashing purposes\.
> 
> 

Remember \- just because you're using the \.NET 4\.0 Framework\, the
64bit and 32bit versions could still be as different as 1\.1 and 2\.0
were\. In fact\, looking at the implementation of String\.GetHashCode
reference source code we see that *it is indeed completely
different*: \(notice the \#if WIN32\)

``` csharp

public override int GetHashCode() {
 
...

#if WIN32
            // 32bit machines. 
            int* pint = (int *)src;
            int len = this.Length;
            while(len > 0) {
                hash1 = ((hash1 << 5) + hash1 + (hash1 >> 27)) ^ pint[0]; 
                if( len <= 2) {
                    break; 
                } 
                hash2 = ((hash2 << 5) + hash2 + (hash2 >> 27)) ^ pint[1];
                pint += 2; 
                len  -= 4;
            }
#else
            int     c; 
            char *s = src;
            while ((c = s[0]) != 0) { 
                hash1 = ((hash1 << 5) + hash1) ^ c; 
                c = s[1];
                if (c == 0) 
                    break;
                hash2 = ((hash2 << 5) + hash2) ^ c;
                s += 2;
            } 
#endif
#if DEBUG 
            // We want to ensure we can change our hash function daily. 
            // This is perfectly fine as long as you don't persist the
            // value from GetHashCode to disk or count on String A 
            // hashing before string B.  Those are bugs in your code.
            hash1 ^= ThisAssembly.DailyBuildNumber;
#endif

...

        }
    } 
}
```
What's really interesting to me is the DEBUG part of the code\,
where the implementers of the method go to extreme lengths to let
other developers know that persisting the value from GetHashCode is
evil\. That says it all really\.

## The moral of the story

I just want to drive this home: **do not persist results
from GetHashCode ever\, under any circumstances\.** If you do
want to store the hash of something\, use an algorithm that was
intended for this\, e\.g\. MD5\, SHA1\, SHA256\, etc\.

