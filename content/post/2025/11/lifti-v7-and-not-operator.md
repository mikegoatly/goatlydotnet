---
title: "LIFTI v7: The And-Not Operator"
date: 2025-11-23
description: "Implementing the &! operator for excluding results in LIFTI query syntax"
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

LIFTI v7 introduces a new query operator that's been on my wishlist for a while: the And-Not operator (`&!`). This operator allows you to efficiently subtract one set of search results from another - perfect for those "find this but not that" scenarios.

## The use case

Imagine you're searching a collection of documents about Paris. You want documents mentioning "eiffel" but you're specifically *not* interested in the tower - maybe you're researching the engineer Gustave Eiffel himself. With the new operator, you can write:

``` csharp
var results = index.Search("eiffel &! tower");
```

This returns documents containing "eiffel" while excluding any that also mention "tower". Simple and intuitive.

## How it works

The `&!` operator is a binary operator that performs a set difference operation. Under the hood, it's implemented as `AndNotQueryOperator` which extends the `BinaryQueryOperator` base class.

The evaluation logic is straightforward but has a neat optimization in line with the other similar binary operators:

``` csharp
public override IntermediateQueryResult Evaluate(
    Func<IIndexNavigator> navigatorCreator, 
    QueryContext queryContext)
{
    // Evaluate left side first
    var leftResults = this.Left.Evaluate(navigatorCreator, queryContext);

    if (leftResults.Matches.Count == 0)
    {
        // Nothing to subtract from
        return IntermediateQueryResult.Empty;
    }

    // Only evaluate right side for documents that matched left
    var documentFilter = leftResults.ToDocumentIdLookup();
    if (queryContext.FilterToDocumentIds != null)
    {
        documentFilter = [.. queryContext.FilterToDocumentIds
            .Intersect(documentFilter)];
    }

    var rightResults = this.Right.Evaluate(
        navigatorCreator,
        queryContext with { FilterToDocumentIds = documentFilter });

    var timing = queryContext.ExecutionTimings.Start(this, queryContext);
    var results = leftResults.Except(rightResults);
    return timing.Complete(results);
}
```

The key optimization is that we only evaluate the right-hand side for documents that appear in the left-hand results. There's no point checking if document 42 contains "tower" if it didn't contain "eiffel" in the first place. This filtering can significantly reduce the work needed for the right-hand query evaluation.

Once we have both result sets, we call `leftResults.Except(rightResults)` which does the actual set difference, preserving all the scoring and field match information from the left side.

## Parsing the operator

The query parser needed minimal changes to support `&!`. The tokenizer recognizes it as a distinct token type:

``` csharp
case '&':
    if (this.ConsumeIf('!'))
    {
        return QueryTokenType.AndNotOperator;
    }
    // ... existing & handling
```

And the parser treats it like any other binary operator:

``` csharp
case QueryTokenType.AndNotOperator:
    var rightPart = this.CreateQueryPart(
        fieldLookup, state, state.GetNextToken(), null);
    return CombineParts(
        currentQuery, rightPart, token.TokenType, token.Tolerance);
```

## Precedence matters

One interesting detail is the operator precedence. The `&!` operator has the same precedence as OR, which might seem counterintuitive at first. However, this makes sense when you consider complex queries:

``` csharp
// These are equivalent - & has higher precedence than &!
food & cake &! cheese
(food & cake) &! cheese
```

This means the AND operation binds tighter, which feels natural when reading the query: "find food AND cake, but NOT cheese".

## Query execution plans

The And-Not operator also integrates with LIFTI's query execution plan visualization. It appears as an `Except` node in the plan tree, making it easy to debug complex queries:

``` csharp
var results = index.Search("eiffel &! tower", 
    QueryExecutionOptions.IncludeExecutionPlan);
var plan = results.GetExecutionPlan();
Console.WriteLine(plan.ToString());
```

## More examples

``` csharp
// Documents about Paris excluding museums
index.Search("paris &! museum")

// Technical articles excluding beginner content
index.Search("technical &! (beginner | tutorial)")

// Field-restricted exclusions
index.Search("title=important &! content=spam")
```

One important note: the `&!` operator requires a left-hand operand. You can't start a query with `&! term` - that wouldn't make sense anyway since there's nothing to subtract from!

That's it! The And-Not operator is a simple but powerful addition to LIFTI's query syntax that makes exclusion queries much more elegant.

