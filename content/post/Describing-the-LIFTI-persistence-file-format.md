---
title: "Describing the LIFTI persistence file format"
date: "2011-04-08T00:00:00.0000000"
author: "Mike Goatly"
---
This post will break down how the data in a LIFTI persisted full
text index is structured on disk\. It might be a bit dry for some\,
so I've tried to spice it up as much as possible with pretty
pictures\!

## Birds\-eye view

![image](/images/post/Windows-Live-Writer_Structure-of-the-LIFTI-page-data_C4E8_image_thumb.png)

The file is broken up into two areas\, headers and page data\.
Each data page is is 8Kb in length and contains 1 or more entries\.
\(The only time you might find a page that is not marked as unused
and still contains 0 entries is when the index is completely
empty\.\)

There are two types of data pages\, **item index
pages** and **index node pages**\.

Item index pages contain entries that describe the actual items
\(keys\) indexed within in the full text index\. Each item is
allocated its own unique ID\, an Int32\, which is used to refer to
the item elsewhere in the file\.

Index node pages contain information about the nodes in the
n\-ary tree\. As with the entries in the item data pages\, each node
is allocated its own unique ID\.

## File headers

![image](/images/post/Windows-Live-Writer_Structure-of-the-LIFTI-page-data_C4E8_image_thumb_1.png)

The index header starts with a known array of 6 bytes followed
by the version number of the persisted index file format\. This
section is used to verify that the file is indeed a LIFTI data
file\, and that the current assembly is capable of reading it\.

The page manager header contains the total number of data pages
that the file currently contains \(including any unused pages\) and
pointers to the first index node data page\, and the first item data
page\.

Also contained here are the next sequential IDs that will be
allocated to new entries contained within the different varieties
of data pages\.

## Data page headers

Both data page types start with a header\, structured in the
following way:

![image](/images/post/Windows-Live-Writer_Structure-of-the-LIFTI-page-data_C4E8_image_thumb_4.png)

After a byte indicating the type of page follows the next and
previous page numbers\. From this you might correctly infer that
data pages are effectively doubly\-linked lists\, i\.e\. you can
traverse them forwards and backwards\. It's important to note that
because of the way that pages are allocated \(or split\, if you want
to use a SQL Server term\) that the logical order of pages will
significantly differ from their physical order\.

By way of a trivial example\, the pages may be
*physically* ordered like this:

![image](/images/post/Windows-Live-Writer_Structure-of-the-LIFTI-page-data_C4E8_image_thumb_5.png)

But are *logically* ordered like this:

![image](/images/post/Windows-Live-Writer_Structure-of-the-LIFTI-page-data_C4E8_image_thumb_6.png)

The data page header also contains the internal IDs of the first
and last entries in the page\. Entries are stored in ascending order
of their internal IDs throughout the data pages\, so being able to
reference the first and last entry ids in this way allows for a
page containing a specific ID to be located quickly by performing a
binary search\, without loading the data in the page's body\.

Finally\, the data page header describes the number of entries in
the page\, and the current size of the page\, including the data in
the page header\. The size of the page will always be less than or
equal to 8Kb\. Any unused space in a data page will be in an unknown
state and not necessarily zeroed out\.

## Item index pages

![image](/images/post/Windows-Live-Writer_Structure-of-the-LIFTI-page-data_C4E8_image_thumb_2.png)

The item entries contained within an item index page are just
the internal ID of the item followed by the item data itself\.

The item data will be whatever key data is stored in your full
text index\. For example\, if you were storing file paths in your
index\, the item data would be a serialized string\, whereas if you
were storing integer IDs\, the item data would simply be that
integer\.

## Index node pages

If you consider the in\-memory structure of the full text index
\(see the [original LIFTI article](/2010/11/18/lifti-searching-pascal-cased-words.aspx) for a more information
about this\) you might imagine something like this for an index of
URLs against their content:

![image](/images/post/Windows-Live-Writer_Structure-of-the-LIFTI-page-data_C4E8_image_thumb_10.png)

Each node in the tree has one or more *references*\,
either to another node or\, in the case of the end nodes\, to an
indexed item\.

Index node pages contain entries that reflect these references:
*referenced item* entries and *referenced index node*
entries:

![image](/images/post/Windows-Live-Writer_Structure-of-the-LIFTI-page-data_C4E8_image_thumb_3.png)

### Referenced item entries

In addition to the internal index node ID and the ID of the
referenced item\, the word index at which the word was matched is
also persisted\. \(Word index positions are used by positional query
operators\, such as near and preceding\)

One word may be matched in multiple positions for any given item
\- each one of these matches results in a separate entry\.

### Referenced index node entries

These entries contain the index node ID and the ID of the
referenced index node\. In addition they also store the character
associated to the referenced index node\.

Both these entries are best explained by example\, so consider
the index below \- the internal node and item ids are the numbers in
red:

![image](/images/post/Windows-Live-Writer_Structure-of-the-LIFTI-page-data_C4E8_image_thumb_11.png)

The **referenced index node** entries that you
would see in the file are:

|Index node ID|Referenced index node ID|Matching character|
|-|-|-|
|0|1|A|
|1|2|P|
|2|4|P|

And the **referenced item** entries would be:

|Index node ID|Referenced item ID|Matching word position|
|-|-|-|
|4|22|12|
|4|22|86|
|4|37|2|

 

## Summary

At a high level\, that's all there is to the contents of the
persisted file\. It's just a series of entries across a series of
pages\. Of course when it comes to managing the data there is a lot
more that could be discussed\, but I'll save that for another
post\.

