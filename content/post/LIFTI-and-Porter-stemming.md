---
title: "LIFTI and Porter stemming"
date: "2010-12-07T00:00:00.0000000"
author: "Mike Goatly"
---
Back in the [original post](/2010/1/29/creating-a-lightweight-in-memory-full-text-indexer.aspx) where I first introduced LIFTI I
wrote:

> LIFTI will not\.\.\.:
> 
> 
> - Handle word derivatives\, e\.g\. if "Cats" is searched for\,
> objects containing just the word "Cat" would not be returned\.
> 
> 

This was always something that I wanted to handle\, but felt that
it was better to have a simple system that actually worked than an
incomplete complex system\. I've been a bit slack in updating the
LIFTI code\, but this has always been at the top of my list of
things to implement\.

As it turns out\, once I actually got down to it\, it has been
pretty easy adding this feature on top of the existing code\.

### Introducing Porter stemming

A full 30 years ago a chap called Martin Porter had a piece of
work entitled "An algorithm for suffix stripping" published in
*Program* magazine\. \([Full history here](http://tartarus.org/~martin/PorterStemmer/)\) This article described a
simple process by which common word suffixes could be removed from
words\, effectively normalizing them to their base form\. For example
**connection**\, **connects** and
**connecting** all become
**connect**\.

Assuming that the words being indexed and the words being
searched upon are all normalized using the same process\, searching
for **connecting** in the index will begin to return
items indexed against all forms of the word\.

Over the years\, Martin has refined this process and I've used an
implementation of the Porter2 algorithm to stem words in LIFTI\.
You'll find loads of information about this algorithm on [Martin's site](http://snowball.tartarus.org/algorithms/english/stemmer.html)\.

### It's a word splitter again

Much like the [previous LIFTI article](/2010/11/18/lifti-searching-pascal-cased-words.aspx)\, Porter stemming can be
introduced into LIFTI by creating a new word splitter
implementation \- each word the splitter returns having been passed
through the stemming process\.

You'll find the implementation of the new word splitter in the
updated [LIFTI
codebase](http://lifti.codeplex.com/) in the **StemmingWordSplitter** class \-
it's a pretty lightweight in its own right\, as it relies heavily on
the supporting Porter stemming implementation that you'll find
lurking in the **Lifti\.PorterStemmer** namespace\.

By default the default word splitter is unchanged\, so in order
to make use of the stemming word splitter you'll need to construct
your full text indexer like this:

``` csharp

var indexer = new FullTextIndexer<MyThing>(t => t.Description)
{
    WordSplitter = new StemmingWordSplitter() 
};
```
### What's the catch?

Introducing a stemming algorithm into LIFTI has a few benefits\,
including:

- The overall index will be *smaller* because all the
indexed words will be stemmed prior to being stored\.
- You have to be less careful about search words; searching for
**cats** would now return objects indexed against
**cat**\.

However this power is not without cost \- stemming words
introduces additional overhead during indexing and searching\. To
give you some feel for how much extra cost is involved I've updated
the original comparison code to run an additional set of
performance tests for an index built with a stemming word
splitter\.

> Note that these results have been produced on my slightly less
> powerful laptop\, so the figures may be slightly worse than in the
> original article\, which were obtained on a workstation\.
> 
> 

||Number of results \(simple\)|Time in ms \(simple\)|Number of results \(stemmer\)|Time in ms \(stemmer\)|
|-|-|-|-|-|
|**Initialize index**|N/A|6\.75ms|N/A|22\.47ms|
|**Search: Jack tells**|5|0\.0067ms|8|0\.0172ms|
|**Search: boars**|1|0\.0026ms|3|0\.0089ms|
|**Search: jack**|25|0\.0023ms|25|0\.009ms|
|**Search: marshal**|4|0\.0027ms|4|0\.0094ms|

From these figures it becomes apparent that using a stemming
word splitter is about 1/3 as fast as the simple word splitter\,
though hopefully you'll agree that it's more than 3 times as useful
for some scenarios\!

### But what does it all mean?

What this means is that LIFTI is starting to become useful in a
broader set of circumstances and it almost becomes useable for
indexing more meaningful text\, such as documents

I suspect however there's still quite some way to go before this
becomes practical; features like index persistence and the ability
to update and remove indexed items will probably be essential\. I'm
already on the case with the thinking process for these features\,
but if there's anything else that you think would be good to add\,
feel free to leave me a comment here or on the [discussions board on the LIFTI CodePlex
site](http://lifti.codeplex.com/discussions)\.

