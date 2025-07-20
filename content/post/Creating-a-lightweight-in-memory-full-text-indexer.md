---
title: "Creating a lightweight in-memory full text indexer"
date: "2010-01-29T00:00:00.0000000"
author: "Mike Goatly"
---

### Introduction

SQL Server provides a really powerful full text index feature
whereby you can run queries along the lines of *"find me
comments that contain the words 'success' and 'happy'"*\. That's
all well and good when you are using SQL Server to retrieve data\,
but what do you do if you're using some other data store\, e\.g\. SQL
Server Compact\, a flat file\, or even a set of \.NET objects\, and
need to do something similar? In this sort of situation it would be
helpful to be able to construct a searchable object model from your
data\, whatever that may be\.

This article will begin to describe an approach to implementing
this \- LIFTI\, the Lightweight In\-memory Full Text Indexer\. Whilst
the initial code may not be the most efficient implementation\, it
is intended to communicate the basic principles for what the
project is trying to achieve\.

The associated code is available on [CodePlex](http://lifti.codeplex.com/)\.

### Features and limitations

So what will LIFTI be able to do?

- Index a set of objects against some representative text
- Return the subset of objects that *contain* or *start
with* one more given search words\. For example searching for
"Cat" would return objects with the words **Cat**\,
**Cat**alan\, **Cat**s\, etc\, but not
Thunder**cat**\.

LIFTI will not\.\.\.:

- Handle word derivatives\, e\.g\. if "Cats" is searched for\,
objects containing just the word "Cat" would not be returned\.
- Do any of the other funky stuff that SQL Server full text index
allows you to do\, like specifying that words must be near one
another in order to match\, etc\.

### Defining the API

The main API is pretty simple:

[ED869F22AB5C24A8_473_0](/images/post/Windows-Live-Writer_f398ddf47af6_A2A0_ED869F22AB5C24A8_473_0_thumb.png)

There is an overloaded method to index an item or items
\(**Index**\) and another to search for the indexed
items that contain one or more words \(**Search**\)\.

The **IndexText** property is a delegate capable of
reading the text from an item that it should be indexed on\, and the
**WordSplitter** property provides access to a class
that is able to split a piece of text into its constituent
words\.

### Indexing words

Ok\, down to business\, how are items going to be indexed against
a set of words? Let's consider a simple class\,
**Company**\, and we just want to index them by the
words in their names\. The data that we have is:

|Id|Name|
|-|-|
|**1**|Magic Madness|
|**2**|Surely Surreal|
|**3**|Mulberry Supply|
|**4**|Magic Mulberry|

The unique words are \(sorted alphabetically\):

|Word|Companies|
|-|-|
|**Madness**|1|
|**Magic**|1\,4|
|**Mulberry**|3\,4|
|**Supply**|3|
|**Surely**|2|
|**Surreal**|2|

The simple approach to searching these words would be to just
iterate through them and compare them with each search criteria in
turn\. This would not scale particularly well \- consider the
following searches:

- Searching for the word **Tiny** would require
**6** character comparisons \(**M**\,
**M**\, **M**\, **S**\,
**S** and **S**\) to identify that none of
the words match\.
- Searching for words beginning with **Sur** would
require **11** character comparisons
\(**M**\, **M**\, **M**\,
**SU**\, **SUR** and **SUR**\)
to yield the 2 appropriate results\.

Visualising these words as simply chains of individual letters\,
it becomes apparent that there is a significant amount of redundant
information at the start of the words \(the duplicated sections are
highlighted in red\):

[ED869F22AB5C24A8_473_1](/images/post/Windows-Live-Writer_f398ddf47af6_A2A0_ED869F22AB5C24A8_473_1_thumb.png)

Surely comparing the same substrings multiple times is a waste
of time \- whether it matches with a search word will not change on
a word\-by\-word basis\. A better way of storing this data is as a set
of trees:

[ED869F22AB5C24A8_473_2](/images/post/Windows-Live-Writer_f398ddf47af6_A2A0_ED869F22AB5C24A8_473_2_thumb.png)

Now with the data in this type of structure\, things look a
little better when considering the two previous examples:

- Searching for **Tiny** would just require
**2** character comparisons\, \(**M** and
**S**\) to identify that there are no appropriate
matches\.
- Searching for words beginning with **Sur** would
now require just **4** character matches
\(**M**\, **SUR**\) to identify that there
are 2 words\.

### Implementing the word index tree

We can implement a tree as described previously very easily
using a self\-referencing class\, defined as:

[ED869F22AB5C24A8_473_3](/images/post/Windows-Live-Writer_f398ddf47af6_A2A0_ED869F22AB5C24A8_473_3_thumb.png)

A **WordIndexNode** represents a single node in the
tree\, and each instance can have zero or more children\,
representing the characters that are known to follow on from it\.
Instances that match the end of a word will also contain a list of
items whose indexed text contains the word\.

A hierarchy of **WordIndexNode**s can be built up
by calling **IndexItem** on a root node\, e\.g\.

``` csharp

rootNode.IndexItem(customer, "Mighty");
```
Note that the root node doesn't actually represent a character
in itself \- it is actually the starting point from which all the
first letters of the words will be stored\.

The **IndexItem** method is implemented as
follows:

``` csharp

public void IndexItem(TItem item, string word)
{
    this.IndexItemCharacter(item, word, 0);
}
 
private void IndexItemCharacter(TItem item, string word, int characterIndex)
{
    if (characterIndex == word.Length)
    {
        // This node represents the last character of the word
        this.AddNodeItem(item);
    }
    else
    {
        var childNode = this.GetOrCreateChildNode(word[characterIndex]);
 
        // Index the next character of the word in the child node
        childNode.IndexItemCharacter(item, word, ++characterIndex);
    }
}
```
### Searching for items in the word index tree

Once the tree has been constructed with all the items indexed
against their relevant text\, we need to be able to navigate the
tree and pull out the items that match or start with a given
word\.

This process is actually really simple \- starting at the root
node\, try to match the child node with the first letter\, from that
node match the second letter and so on until all the letters of the
search word have been matched\. The items stored at the node that
was ultimately matched have one or more words that match the search
word\, and items that are stored against any of this node's children
have words that partially match the search criteria\. In code:

``` csharp

private IEnumerable<TItem> MatchWord(string searchWord)
{
    var currentNode = this.rootNode;
 
    foreach (char letter in searchWord)
    {
        currentNode = currentNode.Match(letter);
 
        if (currentNode == null)
        {
            // This search word matches no items
            break;
        }
    }
 
    if (currentNode == null)
    {
        // No items were matched
        return new TItem[0];
    }
    else
    {
        // Return the items stored at and beneath the resulting node
        return currentNode.GetDirectAndChildItems();
    }
}
```
### Splitting words

Having the ability to split a chunk of text into its constituent
words is fundamental to the indexing process\, whether it's the
breaking up of the text to index an item against\, or the separation
of words within search criteria\.

To keep things fairly simple\, we will for now consider sections
of text separated by whitespace and other word\-breaks\, such as full
stops and hyphens\, to be discreet words\, and characters that are
not letters or digits will be ignored\. The only special case that
will be handled is apostrophes\, which will simply be skipped over
without causing a word break\.

This means that the text:

> Simon's latest phrase is "space\-monkeys rule"
> 
> 

Would effectively contain the words:

- *Simons*
- *latest*
- *phrase*
- *is*
- *space*
- *monkeys*
- *rule*

One last thing that the word splitter will be responsible for is
ensuring that each word it returns is unique \- this will save the
indexer from indexing the same word multiple times against one
item\, or searching for the same word multiple times\.

``` csharp

public IEnumerable<string> SplitWords(string text)
{
    return this.EnumerateWords(text).Distinct();
}
 
private IEnumerable<string> EnumerateWords(string text)
{
    StringBuilder currentWord = new StringBuilder();
    foreach (char character in text)
    {
        if (Char.IsLetterOrDigit(character))
        {
            // This is a character of a word, so add it to the current word
            currentWord.Append(character);
        }
        else if (character != '\'' &&
            (Char.IsSymbol(character) ||
            Char.IsPunctuation(character) ||
            Char.IsWhiteSpace(character)))
        {
            if (currentWord.Length > 0)
            {
                // Characters have been processed in the current word
                // Yield it, and start a new word
                yield return currentWord.ToString();
                currentWord.Length = 0;
            }
        }
    }
 
    if (currentWord.Length > 0)
    {
        // Characters have been processed in the current word - this
        // is the last in the text, so ensure it is yielded
        yield return currentWord.ToString();
    }
}
```
### Searching for multiple words

There is only one part of the original FullTextIndexer class
defined at the start of this article that still needs to be
implemented: the **Search** method\.

The **MatchWord** method discussed previously
allows for the searching of one word within the index\, returning
the list of items that were indexed against it\, but the search
method can be used with multiple words\. What we are interested in
then\, is the list of items that exist in all the sets of items
returned for all the search words\.

For example\, if "Tea cake" was searched for\, we might get the
following results for the different words:

[ED869F22AB5C24A8_473_4](/images/post/Windows-Live-Writer_f398ddf47af6_A2A0_ED869F22AB5C24A8_473_4_thumb.png)

The set that is ultimately relevant is the intersection of the
two sets\, i\.e\. the results that appear in both:

 

Fortunately there a nice extension method that does most of the
work for us here:
**IEnumerable<T>\.Intersect**\.

[ED869F22AB5C24A8_473_5](/images/post/Windows-Live-Writer_f398ddf47af6_A2A0_ED869F22AB5C24A8_473_5_thumb_1.png)

The implementation of the Search method\, detailed below\, uses
the word splitter to separate out the words in the search text\, get
the sets of results for each of the words and returns the
intersection of all the results:

``` csharp

public IEnumerable<TItem> Search(string searchCriteria)
{
    // Break out the words to search on
    var searchWords = this.WordSplitter.SplitWords(searchCriteria).ToArray();
 
    if (searchWords.Length == 0)
    {
        return new TItem[0];
    }
    else
    {
        var wordResults = new List<IEnumerable<TItem>>(searchWords.Length);
 
        foreach (string searchWord in searchWords)
        {
            wordResults.Add(this.MatchWord(searchWord));
        }
 
        // Return the set of items that match ALL of the words by 
        // performing an intersection of all the results
        IEnumerable<TItem> results = wordResults[0];
        for (int i = 1; i < wordResults.Count; i++)
        {
            results = results.Intersect(wordResults[i]);
        }
        return results;
    }
}
```
### Performance analysis

Included in the LIFTI solution is a project that compares the
performance of the full text index against that of a more basic
approach\, similar to that described at the start of this article\.
Indexes are built for 47 items\, containing in total 1075 unique
words and on average 60 words each to index on\. The following table
breaks down the relevant timings:

||Number of results|LIFTI average time|Basic approach average time|
|-|-|-|-|
|**Initialize index**|N/A|5\.445ms|3\.955ms|
|**Search: airplane**|2|0\.005ms|0\.0386ms|
|**Search: boar**|3|0\.0022ms|0\.0438ms|
|**Search: jack**|25|0\.0022ms|0\.0412ms|
|**Search: marshal**|4|0\.0026ms|0\.042ms|
|**Search: transmission**|2|0\.0032ms|0\.0268ms|
|**Search: wheelchair**|1|0\.003ms|0\.0292ms|
|**Search: zebedee**|0|0\.003ms|0\.0416ms|

As you can see\, building the index is marginally slower by
1\.5ms\, however searching is on average over 10 times as fast\. Note
that the approach taken in LIFTI means that as the number of
indexed items\, or more importantly the number of indexed words\,
increases\, the search time will not significantly degrade\, whereas
with the basic implementation it will degrade in a more linear
fashion\.

### Areas for improvement

LIFTI is good\, but whilst writing this article I've been
intrigued as to how much it can be optimised further\, areas that
have occurred to me are:

- A dictionary isn't always the best lookup mechanism for the
characters stored at a node \- for small numbers of characters a
simple list would be better\.
- For diverse sets of words you end up with long chains of
characters that do not branch off at all \- could there be a better
way of storing substrings that match this pattern?

### Wrapping it all up

That's it for now\, although I will probably be spending more
time looking at LIFTI\. There are certainly things that can be done
to improve it and some good real world examples that it could be
used for that I may try to cover shortly\. Stay tuned\!

