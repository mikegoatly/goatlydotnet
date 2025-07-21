---
title: "PersistedFullTextIndexes with non-primitive types"
date: "2013-05-27T09:03:00.0000000"
author: "Mike Goatly"
---
When you construct a PersistedFullTextIndex with a primitive type\, such as int\, you just need to define it like this:

``` csharp
var index = new PersistedFullTextIndex<int>(filePath);
```
However if you try to do this with something more complicated\, such as a class or even just a Guid\, you’ll get an exception like this:

```
Unable to automatically serialize type Guid
```
This because the framework doesn’t know how to \(de\)serialize these types when reading and writing to the backing file\. In order to get this working\, you have to provide the index with an implementation of ITypePersistence<T> for the type of object that you’ll be serializing\.

For simple types\, such as Guid this is pretty easy – this is a full implementation:

``` csharp
public class GuidPersistence : ITypePersistence<Guid>
{
    public Func<Guid, short> SizeReader
    {
        get
        {
            return g => 16;
        }
    }

    public bool TypeHasDynamicSize
    {
        get
        {
            return false;
        }
    }

    public Action<BinaryWriter, Guid> DataWriter
    {
        get
        {
            return (w, g) => w.Write(g.ToByteArray());
        }
    }

    public Func<BinaryReader, Guid> DataReader
    {
        get
        {
            return r => new Guid(r.ReadBytes(16));
        }
    }
}
```
Notice that the TypeHasDynamicSize property is returning false – this provides an optimisation hint to the index that it doesn’t need to keep querying each item for its size – once it has determined it for one entry\, all others will be the same\.

If your type does vary in size then you’ll need to have:

- TypeHasDynamicSize: return true
- SizeReader: calculate the correct size of the object\, in bytes\.
- DataWriter: write out the objects contents to the given BinaryWriter – the amount of data written out must equal the number of bytes returned by SizeReader otherwise you will corrupt your index\.
- DataReader: read out an object from the given BinaryReader\.

Note that although it’s possible to store your objects entirely in the full text index\, it’s not best practice if they are also stored elsewhere because you will have to keep the data consistent in both places\, which won’t be particularly efficient\.

