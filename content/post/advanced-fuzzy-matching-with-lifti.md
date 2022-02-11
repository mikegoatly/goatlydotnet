---
title: "Advanced fuzzy matching with LIFTI"
date: "2022-02-11T00:00:00.0000000"
author: "Mike Goatly"
description: "How to build a custom query parser to replicate the searching used by Visual Studio's Go To Symbol"
draft: false
toc: false
codeMaxLines: 100
categories:
  - Coding
tags:
  - LIFTI
---

The Visual Studio Go To Symbol feature is smart enough that if you miss out letters it can still match with pretty good accuracy:

![](/images/post/visual-studio-searching.png)

Now that LIFTI support wildcard matching (and [fuzzy matching](https://mikegoatly.github.io/lifti/docs/searching/#fuzzy-matching) too!) I thought this would be a good little demonstration of how you could customize LIFTI to behave in a similar way.

First, let's define a really simple index that's going to store the name of a
token both as the key *and* the text in the index. We'll store the text
case insensitive.

``` csharp
var index = new FullTextIndexBuilder<string>()
    .WithDefaultTokenization(o => o.CaseInsensitive())
    .Build();

index.BeginBatchChange();
await index.AddAsync("QueryPart", "QueryPart");
await index.AddAsync("ExactWordQueryPart", "ExactWordQueryPart");
await index.AddAsync("FuzzyMatchQueryPart", "FuzzyMatchQueryPart");
await index.AddAsync("FullTextIndex", "FullTextIndex");
await index.AddAsync("IFullTextIndex", "IFullTextIndex");
await index.CommitBatchChangeAsync();
```

Now we need to think about how we can query the index. Let's say we wanted to search for `fti` - we'd expect `FullTextIndex` and `IFullTextIndex` to be returned because those letters appear in that order in both.

In terms of a wildcard query, that would be `*f*t*i*`, so we could use the standard LIFTI query parser to do just that:

``` csharp
foreach (var item in index.Search("*f*t*i*"))
{
    Console.WriteLine(item.Key);
}

// Prints:
// FullTextIndex
// IFullTextIndex
```

Alternatively we can skip the query parser and build our own `Query` object (note that because we're skipping the query parser, we need to uppercase the search text to match the indexed characters):

``` csharp
var query = new Query(
    new WildcardQueryPart(
        WildcardQueryFragment.MultiCharacter,
        WildcardQueryFragment.CreateText("F"),
        WildcardQueryFragment.MultiCharacter,
        WildcardQueryFragment.CreateText("T"),
        WildcardQueryFragment.MultiCharacter,
        WildcardQueryFragment.CreateText("I"),
        WildcardQueryFragment.MultiCharacter));

foreach (var item in index.Search(query))
{
    Console.WriteLine(item.Key);
}

// Prints:
// FullTextIndex
// IFullTextIndex
```

But we can do better. We can write our own `IQueryParser` implementation for the index to automatically build the wildcard matching for us:

``` csharp
public class CustomWildcardQueryParser : IQueryParser
{
    public IQuery Parse(IIndexedFieldLookup fieldLookup, string queryText, ITokenizer tokenizer)
    {
        // Use the default tokenizer to normalize the text so it's the same as in the index
        queryText = tokenizer.Normalize(queryText);

        var queryFragments = new List<WildcardQueryFragment>();

        // Add the leading multi-character match
        queryFragments.Add(WildcardQueryFragment.MultiCharacter);

        // Add each character in the query text, with a trailing multi-character match
        foreach (var letter in queryText)
        {
            queryFragments.Add(WildcardQueryFragment.CreateText(letter.ToString()));
            queryFragments.Add(WildcardQueryFragment.MultiCharacter);
        }

        // Compose the final query
        return new Query(new WildcardQueryPart(queryFragments));
    }
}
```

Then we just configure it as the query parser to use in the index, and query just the text that we wanted to initially, `fti`:

``` csharp
var index = new FullTextIndexBuilder<string>()
                .WithDefaultTokenization(o => o.CaseInsensitive())
                .WithQueryParser(new CustomWildcardQueryParser())
                .Build();

index.BeginBatchChange();
await index.AddAsync("QueryPart", "QueryPart");
await index.AddAsync("ExactWordQueryPart", "ExactWordQueryPart");
await index.AddAsync("FuzzyMatchQueryPart", "FuzzyMatchQueryPart");
await index.AddAsync("FullTextIndex", "FullTextIndex");
await index.AddAsync("IFullTextIndex", "IFullTextIndex");
await index.CommitBatchChangeAsync();

// Now just use the simple search terms
foreach (var item in index.Search("fti"))
{
    Console.WriteLine(item.Key);
}

// Yep, it still prints:
// FullTextIndex
// IFullTextIndex
```

I've put together a .NET Fiddle with the final example [over here](https://dotnetfiddle.net/RAv6r1) for you to play with.

That's it - hopefully this shows how easy it can be to swap out the default query parser with something that meets your needs.