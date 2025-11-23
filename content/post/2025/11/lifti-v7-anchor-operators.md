---
title: "LIFTI v7: Anchoring Queries to Field Boundaries"
date: 2025-11-25
description: "Using << and >> operators to match text at the start or end of fields"
draft: false
toc: false
codeMaxLines: 100
categories:
  - Coding
tags:
  - LIFTI
  - Full Text Search
  - C#
---

> LIFTI is an open source full text index library for .NET - you can check it out on [GitHub](https://github.com/mikegoatly/lifti)

LIFTI v7 introduces anchor operators that let you constrain matches to the start or end of fields. This feature was requested for exact match scenarios - like finding records where a field contains *exactly* one specific value, or where text starts or ends with particular words.

## The syntax

The anchor operators are simple:

* `<<term` - matches when "term" appears as the first token in a field
* `term>>` - matches when "term" appears as the last token in a field  
* `<<term>>` - matches when "term" is both the first *and* last token (i.e., the entire field content)

Here's how you might use them:

``` csharp
// Find cars where the brand is exactly "Skoda"
index.Search("Brand=<<Skoda>>")

// Find documents where *any* field's text starts with "The"
index.Search("<<The")

// Find descriptions ending with "excellent"
index.Search("Description=excellent>>")
```

## Token positions are the key

To implement this feature, LIFTI needed to track the position of the last token in each field. Previously, we only tracked token counts. This required changes to the serialization format and a new `FieldStatistics` record:

``` csharp
public record FieldStatistics
{
    public int TokenCount { get; init; }
    public int LastTokenIndex { get; init; }  // NEW in V7
}
```

During indexing, we now capture both the total token count and the index of the final token for each field. This metadata enables precise positional matching.

## Implementation details

The `AnchoredWordQueryPart` class handles the evaluation. First, it performs a normal exact word match, then filters the results based on the anchor requirements:

``` csharp
public override IntermediateQueryResult Evaluate(
    Func<IIndexNavigator> navigatorCreator, 
    QueryContext queryContext)
{
    var timing = queryContext.ExecutionTimings.Start(this, queryContext);
    using var navigator = navigatorCreator();
    navigator.Process(this.Word.AsSpan());
    var results = navigator.GetExactMatches(queryContext, this.ScoreBoost ?? 1D);

    // Filter results based on anchor requirements
    var filteredResults = this.FilterByAnchors(results, navigator.Snapshot.Metadata);

    return timing.Complete(filteredResults);
}
```

The filtering logic examines each match location against the field's last token index:

``` csharp
private bool IsAnchorMatch(int minTokenIndex, int maxTokenIndex, int lastTokenIndex)
{
    if (this.RequireStart)
    {
        if (this.RequireEnd)
        {
            // Both anchors: must include index 0 AND the last token
            return minTokenIndex == 0 && maxTokenIndex == lastTokenIndex;
        }

        // Start anchor only: must include index 0
        return minTokenIndex == 0;
    }

    // End anchor only: must include the last token index
    return maxTokenIndex == lastTokenIndex;
}
```

This approach handles both single tokens and composite locations (like those from sequential text queries). For a match to be valid, the token position range must include the required boundary position(s).

## Combining with other operators

Anchor operators work seamlessly with LIFTI's other query features:

``` csharp
// Wildcard matching at field start
index.Search("Brand=<<Sk*")  // Matches "Skoda", "Škoda", "Ski"

// Fuzzy matching for exact fields
index.Search("Status=<<?Activ>>")  // Matches "Active" with typo tolerance

// Multiple conditions
index.Search("Title=<<The & Description=excellent>>")

// Sequential text anchoring
index.Search("\"<<The West\"")  // Phrase must start the field
```

## Why not just use field filters?

You might wonder why not just use field filters like `Brand=Skoda` without the anchors. The difference is that a normal field filter matches anywhere in the field:

``` csharp
// Without anchors - matches "New Skoda" and "Skoda Octavia"
index.Search("Brand=Skoda")

// With start anchor - only matches "Skoda Octavia", not "New Skoda"  
index.Search("Brand=<<Skoda")

// Both anchors - only matches exact "Skoda"
index.Search("Brand=<<Skoda>>")
```

This precision is particularly useful for categorical fields or when you need to distinguish between "title starts with X" versus "title contains X somewhere".

## Deserializing older indexes

LIFTI maintains backwards compatibility with V6 indexes. When deserializing an older index, the `LastTokenIndex` values are calculated on-the-fly from the existing token locations. However, for optimal performance, it's recommended to re-index your data with V7 to persist these statistics.

## Testing the edge cases

The implementation needed careful testing for various scenarios. Here's a snippet from the test suite showing the "exact match" case:

``` csharp
[Fact]
public void EvaluatingNavigationInIndex_WithBothAnchors_ShouldOnlyReturnExactMatches()
{
    var sut = new AnchoredWordQueryPart("test", requireStart: true, requireEnd: true);

    var matches = new[]
    {
        ScoredToken(1, ScoredFieldMatch(1D, 1, 0)),     // Single token (MATCH)
        ScoredToken(2, ScoredFieldMatch(1D, 1, 0)),     // Token at 0, field has 5 tokens (NOT MATCH)
        ScoredToken(3, ScoredFieldMatch(1D, 1, 0))      // Single token (MATCH)
    };

    var metadata = new FakeIndexMetadata<int>(
        3,
        documentMetadata:
        [
            (1, DocumentMetadata.ForLooseText(1, 1, 
                new(new Dictionary<byte, FieldStatistics> { { 1, new(1, 0) } }, 1))),
            (2, DocumentMetadata.ForLooseText(2, 2, 
                new(new Dictionary<byte, FieldStatistics> { { 1, new(5, 4) } }, 5))),
            (3, DocumentMetadata.ForLooseText(3, 3, 
                new(new Dictionary<byte, FieldStatistics> { { 1, new(1, 0) } }, 1)))
        ]);

    // ... test continues
}
```

Notice how documents 1 and 3 have `LastTokenIndex: 0` (single token fields), while document 2 has `LastTokenIndex: 4` (five token field). Only the single-token matches pass the filter.

## Summary

Anchor operators are particularly useful for:

- Exact categorical field matching
- Title/heading prefix matching  
- Sentence ending detection
- Record validation queries

The combination of anchor operators with wildcards and fuzzy matching opens up some interesting query possibilities. Give them a try and see how they can make your searches more precise!

