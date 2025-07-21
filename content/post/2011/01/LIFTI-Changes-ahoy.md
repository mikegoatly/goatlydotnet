---
title: "LIFTI-Changes ahoy"
date: "2011-01-05T00:00:00.0000000"
author: "Mike Goatly"
---
Happy new year\! If anyone has been following the recent
check\-ins that have been happening over on the [LIFTI CodePlex
site](http://lifti.codeplex.com/) will have noticed quite a bit of activity over the
Christmas period\. In this article\, I'll try to summarise what those
changes have been and why they were introduced in the way that they
were\.

In short\, these changes are:

- Query parsing
- Updatable indexes
- Index serialization and de\-serialization

## Breaking Changes

Before I go any further\, it's probably
worth noting this: the only breaking change \(that comes to mind
now…\) is that the FullTextIndexer class has been renamed
FullTextIndex\. The bottom line is that it just feels better I
wanted to change it before it was in too much use\.

## Indexing Keys vs \.NET Objects

### Indexing \.NET Objects

This almost fell into the
breaking\-change category\, but it's actually a change to my
recommended approach for indexes\. Up until now I have always
provided sample code along the following lines:

``` csharp

var index = new FullTextIndex<Customer>(c => c.CustomerText);
```
This defined an index that contained a
set of customers\. The text these objects were indexed against is
*contained within* the customer instances\.

This has the drawback that all the
text being indexed is actually stored **in memory**\,
which is not ideal\, especially when it comes to indexing large
documents\.

### Indexing Keys

The approach I would promote now is
along these lines:

``` csharp

var index = new FullTextIndex<int>(i => GetCustomerText(i));
```
Now the index will only contain
references to an item\. When an item is indexed\, a method \(in this
case GetCustomerText\) is used to fetch the relevant text \- this
might be from a database\, a file\, an object in memory\, etc\.

So why change approach? Well\, the
reduced memory footprint of the index is a benefit\, but the main
reason is to support serialization\.

Lets say that you were to attempt to
serialize an index using the \.NET object\-based approach: you would
need to either write the entire object out\, or you just just write
out the primary identifier for the item\, e\.g\. the customer id\.

The first option is bad because you're
duplicating the data that you've probably got elsewhere\, the second
option isn't so bad\, but when you come to de\-serialize the index
again you're going to have to get the information from somewhere
else\. Indexing just an item's keys alleviates both these
problems\.

## Query parsing

I've already covered the introduction
of the advanced LIFTI querying engine in [this post](/2010/12/24/advanced-querying-with-lifti.aspx)\. This change required quite a bit of
refactoring as I wanted to allow for different types of query
parsers to be plugged in\.

Why? Three reasons\, really\.

1. Extensibility is something I want to
focus on with LIFTI \- allowing people to adapt the behaviour of a
full text index is a good thing\.
1. I was worried that people weren't
going to like the LIFTI query language meaning I would have to
completely rewrite the code\. This way I can keep the LIFTI query
language and add a new query parser to suit other people's
tastes\.
1. I wanted to enable people to be able
to put together their own query parsers that were specific to their
domains \- this way you don't have to parse a user's query to get it
into a format suitable for LIFTI; it can be parsed directly in the
index's Search method\.

## Updatable indexes

I also introduced a new
UpdatableFullTextIndex class \- this derives from FullTextIndex\,
adding in the ability to remove and update items in the index\.

The reasoning behind creating a
derived class rather than simply building the functionality into
the core class is because in order to be able to remove an item
from the index efficiently we need to have a reverse\-index of items
against their associated nodes\, as opposed to the tree\-like
structure the index consists of\.

This additional index means more
overhead in terms of memory and CPU \(when indexing\)\, and I didn't
want to penalise people who just wanted a simple write\-once
index\.

## Serializing and de\-serializing indexes

I've already highlighted the new key\-based indexing approach
above\, so I'll not bang on about it\. Here's how you'd take an
index\, serialize it and de\-serialize it to a new instance using the
new BinarySerializer class:

``` csharp

// Create the original index
var originalIndex = new FullTextIndex<int>(i => GetText(i));

PopulateIndex(originalIndex);

// Create a serializer - this is capable of both serializing and 
// deserializing
var serializer = new BinarySerializer<int>();
byte[] serializedData;
using (var stream = new MemoryStream())
{
    // Serialize the data
    serializer.Serialize(originalIndex, stream);
    serializedData = stream.ToArray();
}

// Create an index to deserialize the data into
var deserializedIndex = new FullTextIndex<int>(i => GetText(i));
using (var stream = new MemoryStream(serializedData))
{
    // Deserialize the data - job done!
    serializer.Deserialize(deserializedIndex, stream);
}
```
At the moment I've implemented only binary serialization\, but in
theory it would be fairly easily put together serializers for other
formats\, e\.g\. XML\.

For keys that are primitive types \(e\.g\. int\, long\, byte\) the
binary serializer is able to automatically serialize the items\. For
other types\, such as Guid\, or your own \.NET object\, you'll need to
instruct the serializer how to read and write your type \- you do
this by providing a delegate to the Serialize or Deserialize
methods\.

For a Guid\, this would look like this:

``` csharp

var serializer = new BinarySerializer<Guid>();
serializer.Serialize(
    index, 
    stream, 
    (binaryWriter, g) => binaryWriter.Write(g.ToString()));

serializer.Deserialize(
    newIndex,
    stream,
    binaryReader => Guid.Parse(binaryReader.ReadString()));
```
So that's it for now\. I'll blog soon in more detail about some
aspects of these changes \- specifically those regarding the
querying object model\, and also the new approaches to indexing\.

This thing is definitely moving towards a usable\, stable\(ish\)
1\.0 form\. There are a couple of features I still want to get in\,
the main one being making the thing thread\-safe\. I'll talk about
that soon as well\.

If there's anything that you want/need LIFTI to do\, now's the
best time to get involved\!

