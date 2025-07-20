---
title: "Implementing a persisted file store for LIFTI"
date: "2011-03-29T00:00:00.0000000"
author: "Mike Goatly"
---
Over a month ago I started to write a persisted file store for
LIFTI\. Given that I'd pretty much just finished implementing binary
serialization for indexes\, why would I want to do that?

## Serialization vs\. persistence

I wrote the serialization classes because I knew that it wasn't
always going to be appropriate to re\-index all the data every time
an application started up\. These classes allowed for the current
state of an index to be saved to and reloaded from disk\. This meant
that when the application **exited**\, a developer
could save what was currently in the index and reload it the next
time it started\. The problem for me lies in the word
**exited**\. At what point would you persist your index
if you application crashed?

There were also larger questions around data integrity \- if you
were indexing your data in LIFTI\, but storing it in another
database \(e\.g\. SQL Express\, SQLLite\, etc\) then you would probably
want to make sure that both are synchronized\. Ideally you would
wrap the calls to both in a single transaction scope and thus
guarantee that they were both in a consistent state should a
failure occurred\.

One option would be to use the serialization process to persist
the entire index after every modifying operation\, but that would be
very inefficient and wouldn't scale\. Persistence\, for me\, is a much
more subtle use of serialization\. When different parts of the index
change \- items are added\, nodes are created in the n\-ary tree \-
only the changed data \(or at least a smallest as possible set of
data\) is serialized to a file\. This happens automatically\, without
any intervention by the user\. When the application is restarted\,
the index can be re\-loaded from disk\, and begin in the state it was
left at when the application was last closed\.

Once the index is being committed to disk immediately\, it
becomes feasible to enlist in a transaction and guarantee
consistency as well as durability\.

## The PersistedFullTextIndex

As of now\, I've implemented only the persisted backing store for
the index\. I'm going to hold off doing another release build until
I've got transactions in place\, but if you're really keen you can
[download the latest source](http://lifti.codeplex.com/SourceControl/changeset/changes/56915) and try it out from
there\.

I'll be documenting the underlying changes that have occurred in
LIFTI to support this over the coming weeks\. To whet your appetite\,
here's a very high level diagram\, starting from the
PersistedFullTextIndex class: \(click for a bigger version\)

[![image](/images/post/Windows-Live-Writer_Implementing-a-persisted-file-store-for-_FA97_image_thumb.png)](/images/post/Windows-Live-Writer_Implementing-a-persisted-file-store-for-_FA97_image_2.png)

The transaction work is probably next on my plate for LIFTI\.
This is another interesting chunk of work\, but it should be
fun\.

