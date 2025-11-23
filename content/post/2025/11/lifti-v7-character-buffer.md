---
title: "LIFTI v7: Eliminating Allocations with CharacterBuffer"
date: 2025-11-27
description: "How replacing StringBuilder with a custom CharacterBuffer reduced tokenization allocations by 50%"
draft: false
toc: false
codeMaxLines: 100
categories:
  - Coding
  - Performance
tags:
  - LIFTI
  - Full Text Search
  - C#
  - Performance
---

> LIFTI is an open source full text index library for .NET - you can check it out on [GitHub](https://github.com/mikegoatly/lifti)

Performance has always been a core focus for LIFTI. For v7, I looked at the tokenization pipeline and found an opportunity to significantly reduce memory allocations. The solution? Replacing `StringBuilder` with a custom `CharacterBuffer` backed by `ArrayPool<char>`.

## The problem

During tokenization, LIFTI builds up character sequences from the input text. Previously, this used `StringBuilder` - a perfectly reasonable choice, but one that allocates a new string every time you call `ToString()`. When indexing 100,000 tokens with 50% duplicates, that's roughly 50,000 unnecessary string allocations for tokens we've already seen.

The tokenization flow looked like this:

``` csharp
// OLD approach (simplified)
var tokenBuffer = new StringBuilder(256);

foreach (var character in input)
{
    if (IsSplitCharacter(character))
    {
        if (tokenBuffer.Length > 0)
        {
            stemmer?.Stem(tokenBuffer);  // Modifies the StringBuilder
            var tokenText = tokenBuffer.ToString();  // ALLOCATION
            processedTokens.MergeOrAdd(tokenText, location);
            tokenBuffer.Clear();
        }
    }
    else
    {
        tokenBuffer.Append(preprocessedCharacter);
    }
}
```

Every call to `tokenBuffer.ToString()` creates a new string object, even if we've already indexed that exact token.

## Enter CharacterBuffer

`CharacterBuffer` is a `ref struct` that wraps an array rented from `ArrayPool<char>.Shared`. It provides a similar API to `StringBuilder` but works with `ReadOnlyMemory<char>` instead of allocating strings:

``` csharp
public ref struct CharacterBuffer
{
    private char[] buffer;
    private int length;

    public CharacterBuffer(int initialCapacity)
    {
        this.buffer = ArrayPool<char>.Shared.Rent(initialCapacity);
        this.length = 0;
    }

    public void Append(char c)
    {
        if (this.length >= this.buffer.Length)
        {
            this.Grow();
        }

        this.buffer[this.length++] = c;
    }

    public readonly ReadOnlyMemory<char> AsMemory()
    {
        return this.buffer.AsMemory(0, this.length);
    }

    public void Dispose()
    {
        if (this.buffer is not null)
        {
            ArrayPool<char>.Shared.Return(this.buffer);
            this.buffer = null!;
        }
    }
}
```

The key method is `AsMemory()` - it returns a `ReadOnlyMemory<char>` view over the pooled buffer without allocating a string. This memory can be used as a dictionary key via a custom comparer.

## Zero-allocation deduplication

The `TokenStore` class is responsible for merging duplicate tokens. It now uses `ReadOnlyMemory<char>` as the dictionary key:

``` csharp
internal class TokenStore
{
    private readonly Dictionary<ReadOnlyMemory<char>, Token> materializedTokens = 
        new(ReadOnlyMemoryCharComparer.Instance);

    public Token MergeOrAdd(ReadOnlyMemory<char> tokenText, TokenLocation location)
    {
        if (this.materializedTokens.TryGetValue(tokenText, out var token))
        {
            // Duplicate - just add the location
            token.AddLocation(location);
        }
        else
        {
            // New token - materialize the string once
            var text = tokenText.ToString();
            token = new Token(text, location);
            this.materializedTokens.Add(text.AsMemory(), token);
        }

        return token;
    }
}
```

The clever bit: when we encounter a duplicate token, `TryGetValue` succeeds using the memory-based comparison, and we never call `ToString()`. We only materialize the string when creating a *new* `Token` object.

The custom comparer ensures memory-based equality works correctly:

``` csharp
internal class ReadOnlyMemoryCharComparer : IEqualityComparer<ReadOnlyMemory<char>>
{
    public static ReadOnlyMemoryCharComparer Instance { get; } = new();

    public bool Equals(ReadOnlyMemory<char> x, ReadOnlyMemory<char> y)
    {
        return x.Span.SequenceEqual(y.Span);
    }

    public int GetHashCode(ReadOnlyMemory<char> obj)
    {
        return string.GetHashCode(obj.Span);
    }
}
```

## The new tokenization flow

With `CharacterBuffer`, the tokenization code becomes:

``` csharp
var processedTokens = new TokenStore();
var tokenIndex = 0;
var tokenBuffer = new CharacterBuffer(256);  // Rent from pool

try
{
    foreach (var character in input)
    {
        if (IsSplitCharacter(character))
        {
            if (tokenBuffer.Length > 0)
            {
                stemmer?.Stem(ref tokenBuffer);  // Modifies buffer in-place
                processedTokens.MergeOrAdd(
                    tokenBuffer.AsMemory(),      // NO allocation
                    new TokenLocation(tokenIndex, start, length));
                tokenIndex++;
                tokenBuffer.Clear();
            }
        }
        else
        {
            tokenBuffer.Append(preprocessedCharacter);
        }
    }

    return processedTokens.ToList();
}
finally
{
    tokenBuffer.Dispose();  // Return to pool
}
```

The `try`/`finally` ensures the buffer is always returned to the pool, even if an exception occurs.

## Impact on stemmers

The change to `CharacterBuffer` required updating the `IStemmer` interface:

``` csharp
// OLD
void Stem(StringBuilder builder)

// NEW  
void Stem(ref CharacterBuffer buffer)
```

The `PorterStemmer` implementation was updated to work with `CharacterBuffer` using helper extension methods:

``` csharp
internal static class CharacterBufferExtensions
{
    public static bool EndsWith(this ref CharacterBuffer buffer, string suffix)
    {
        return buffer.EndsWith(suffix.AsSpan());
    }

    public static void ReplaceEnd(
        this ref CharacterBuffer buffer, 
        string oldEnding, 
        string newEnding)
    {
        if (!buffer.EndsWith(oldEnding.AsSpan()))
        {
            return;
        }

        buffer.Length -= oldEnding.Length;
        buffer.Append(newEnding.AsSpan());
    }
}
```

These extensions keep the stemmer code readable while working efficiently with the character buffer.

## The results

For a benchmark indexing 100,000 tokens with 50% duplicates:

- **~50,000 fewer string allocations** (one saved per duplicate token)
- Reduced GC pressure  
- Improved throughput

The pooled arrays are reused across tokenization operations, so the memory overhead is minimal - just the size of the largest token buffer needed.

Making `CharacterBuffer` a `ref struct` ensures it's stack-allocated and can't escape to the heap. The tradeoff is that ref structs can't be used in async methods or stored in fields, but for tokenization (a purely synchronous operation), this is perfect.


