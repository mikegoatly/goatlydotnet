---
title: "LIFTI: Searching Pascal-cased words"
date: "2010-11-18T00:00:00.0000000"
author: "Mike Goatly"
---
This post will show how LIFTI can be adapted to index and search
upon Pascal\-cased words\, similar to Visual Studio 2010's **[
Navigate To](http://blogs.msdn.com/b/zainnab/archive/2010/01/20/how-to-use-navigate-to-vstiptool0006.aspx)** window\. \(Or Resharper's **[
Go to symbol](http://stackoverflow.com/questions/1371241/can-resharper-navigate-to-a-method/1371262#1371262)** command\, if you're so inclined\)

> *The code for this sample can be found in the Lifti
> solution:*[*
> http://lifti\.codeplex\.com/SourceControl/list/changesets*](http://lifti.codeplex.com/SourceControl/list/changesets)*\- you'll find the sample project in the Samples solution
> folder:*
> 
> [![image_thumb9_thumb](/images/post/Windows-Live-Writer_1d2ddffacd3c_75BC_image_thumb9_thumb_thumb.png)](/images/post/Windows-Live-Writer_1d2ddffacd3c_75BC_image_thumb9_thumb_2.png)
> 
> 

The way the default word splitter works is by breaking a phrase
into separate words wherever whitespace characters appear \- by
changing this behaviour to break on changes in capitalisation\,
we're pretty much all the way there:

``` csharp

public IEnumerable<string> SplitWords(string text)
{
    var builder = new StringBuilder();

    foreach (var character in text)
    {
        if (Char.IsUpper(character) && builder.Length > 0)
        {
            yield return builder.ToString();
            builder.Length = 0;
        }

        builder.Append(character);
    }

    if (builder.Length > 0)
    {
        yield return builder.ToString();
    }
}
```
The sample project **VS2010MethodIndexer** indexes
all the methods in all the assemblies currently loaded into a
**FullTextIndexer** instance configured to use the new
Pascal case word splitter:

``` csharp

this.index = new FullTextIndexer<MethodInfo>(m => m.Name);
this.index.WordSplitter = new PascalCaseWordSplitter();
```
Using the UI you're able to search on just the capital letters
of a method name:

[![image_thumb7_thumb](/images/post/Windows-Live-Writer_1d2ddffacd3c_75BC_image_thumb7_thumb_thumb.png)](/images/post/Windows-Live-Writer_1d2ddffacd3c_75BC_image_thumb7_thumb_2.png)

And also a combination of capital letters and partial words:

[![image_thumb6_thumb](/images/post/Windows-Live-Writer_1d2ddffacd3c_75BC_image_thumb6_thumb_thumb.png)](/images/post/Windows-Live-Writer_1d2ddffacd3c_75BC_image_thumb6_thumb_2.png)

That's all for now \- any questions?

