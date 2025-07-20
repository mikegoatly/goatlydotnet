---
title: "LIFTI XmlWordSplitter"
date: "2011-06-10T00:00:00.0000000"
author: "Mike Goatly"
---
The XmlWordSplitter is a new word splitter class in the latest
release of LIFTI\. I created it mainly because it was required for
the persisted index sample\, but it seemed too useful to keep out of
the core framework\.

At a very high level the XmlWordSplitter just enumerates words
contained within elements in a piece of XML text\. This means that
element names\, attributes and their associated values will not be
indexed\. For example\, consider the following XML:

[image](/images/post/Windows-Live-Writer_LIFTI-XmlWordSplitter_CEA3_image_thumb.png)

The xml splitter will return the following words:

|Word|Word index|
|-|-|
|THE|0\, 6|
|QUICK|1|
|BROWN|2|
|FOX|3|
|JUMPED|4|
|OVER|5|
|LAZY|7|
|DOG|8|

Importantly\, notice that the word "the" is reported at positions
0 and 6 \- the word index is relative to first word in the document\,
regardless of whether there are XML elements that interrupt the
flow of the text\.

## To stem or not to stem?

One question that sprung to mind when developing this was
whether the splitter should stem the words it returned\, like the [StemmingWordSplitter](/2010/12/7/lifti-and-porter-stemming.aspx)\, or just return them
verbatim\, like the basic WordSplitter does? \(The above example
would be representative of the latter; a stemming word splitter
would have returned words like "jump" instead of "jumped"\.\)

Taking this question a step further\, what if someone has put
together their own custom word splitter and they want the xml
splitter to behave like that?

To cater for this I decided to defer the splitting of text
contained within XML nodes to a child IWordSplitter implementation\.
So when you construct an XmlWordSplitter\, you do so like this:

``` csharp

var wordSplitter = new StemmingWordSplitter();
var xmlSplitter = new XmlWordSplitter(wordSplitter);
```
So if you don't want the stemming word splitter behaviour for
returned words\, you just need to swap it out for a different
implementation\. Neat\.

## Splitting search words

Previously LIFTI would always use the same word splitter
implementation when splitting words that were being indexed and
words that were being searched upon\. Introducing the
XmlWordSplitter had an interesting side\-effect \- although you were
wanting to index text contained in XML\, you probably didn't want to
search for words contained in an XML format\.

To handle this I added the SearchWordSplitter property to the
IFullTextIndex interface \- this allows you to specify a different
word splitting implementation that should be used when splitting
words in a search string\. As a small token of my [respect to backwards compatibility](/2011/6/8/changes-to-the-lifti-api.aspx)\, if this
property isn't specified or is set to null\, then the splitter
specified in the WordSplitter property is used\, meaning that
behaviour is unaffected for existing code\.

