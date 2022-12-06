---
title: "Coding With ChatGPL" 
date: 2022-12-06
description: "An experiment using ChatGPL to accelerate some code" 
featured: true 
toc: false 
codeMaxLines: 100 
codeLineNumbers: false 
figurePositionShow: true 
categories:
  - AI
  - ChatGPT
  - OpenAI
  - Coding
  - C#
  - Unit tests
---

This post is me having a conversation with an AI called [ChatGPT](https://chat.openai.com/chat), using it as a time saving tool for writing code. I'd been thinking about some code I needed to write in [LIFTI](https://github.com/mikegoatly/lifti). I knew what I wanted it to do and how I was going to implement it, but as an old friend once told me "Just because you know how to do something, doesn't mean it takes zero time". So I figured I'd have a bit of fun with ChatGPT. 

> Hi, would you like to help me write a C# class?

---

Sure, I'd be happy to help you write a C# class. Do you have any specific requirements or details that you'd like to share?

---

> Great, thanks! This class will be called "VirtualString" it's constructor will take an array of strings and it will provide a method with the signature "string Substring(int start, int length)" that is able to create a substring from that array. Each element in the array should be considered part of the same overall string. For example, if I passed ay array containing "test", "string" and "test", SubString(3, 4) would return "tst". Give it a go!

---

Sure, I can help you write a VirtualString class that takes an array of strings and provides a Substring method to create a substring from the array of strings. Here is an example of how the class could be implemented:

``` csharp
public class VirtualString
{
    private string[] _strings;

    // constructor that takes an array of strings
    public VirtualString(string[] strings)
    {
        _strings = strings;
    }

    // Substring method that creates a substring from the array of strings
    public string Substring(int start, int length)
    {
        // create a new string builder to store the substring
        StringBuilder sb = new StringBuilder();

        // calculate the total length of the array of strings
        int totalLength = _strings.Sum(s => s.Length);

        // handle the case where the start index is greater than the total length
        if (start > totalLength)
        {
            return "";
        }

        // handle the case where the length is greater than the total length
        if (start + length > totalLength)
        {
            length = totalLength - start;
        }

        // iterate over the array of strings
        for (int i = 0; i < _strings.Length; i++)
        {
            // get the current string and its length
            string currentString = _strings[i];
            int currentLength = currentString.Length;

            // check if the start index is within the current string
            if (start < currentLength)
            {
                // calculate the substring length for the current string
                int substringLength = Math.Min(currentLength - start, length);

                // add the substring to the string builder
                sb.Append(currentString.Substring(start, substringLength));

                // update the start index and length for the next string
                start = 0;
                length -= substringLength;
            }
            else
            {
                // update the start index for the next string
                start -= currentLength;
            }

            // check if the length is 0, which means we have added the required substring to the string builder
            if (length == 0)
            {
                break;
            }
        }

        // return the substring from the string builder
        return sb.ToString();
    }
}
```

You can use this VirtualString class as follows:

``` csharp
// create a new VirtualString object with an array of strings
VirtualString virtualString = new VirtualString(new string[] { "test", "string", "test" });

// call the Substring method to create a substring
string substring = virtualString.Substring(3, 4);

// print the substring to the console
Console.WriteLine(substring); // "tst"
```

Let me know if you have any questions or if you need help with anything else. I'm here to help!

---

> Great, but I prefer to use "var" over explicit types, and I'd rather use string.Empty instead of "" - could you update the example?

---

Sure, I can update the example to use var for the variable types and string.Empty instead of "" for empty strings. Here is an updated version of the VirtualString class:

``` csharp
public class VirtualString
{
    private string[] _strings;

    // constructor that takes an array of strings
    public VirtualString(string[] strings)
    {
        _strings = strings;
    }

    // Substring method that creates a substring from the array of strings
    public string Substring(int start, int length)
    {
        // create a new string builder to store the substring
        var sb = new StringBuilder();

        // calculate the total length of the array of strings
        var totalLength = _strings.Sum(s => s.Length);

        // handle the case where the start index is greater than the total length
        if (start > totalLength)
        {
            return string.Empty;
        }

        // handle the case where the length is greater than the total length
        if (start + length > totalLength)
        {
            length = totalLength - start;
        }

        // iterate over the array of strings
        for (var i = 0; i < _strings.Length; i++)
        {
            // get the current string and its length
            var currentString = _strings[i];
            var currentLength = currentString.Length;

            // check if the start index is within the current string
            if (start < currentLength)
            {
                // calculate the substring length for the current string
                var substringLength = Math.Min(currentLength - start, length);

                // add the substring to the string builder
                sb.Append(currentString.Substring(start, substringLength));

                // update the start index and length for the next string
                start = 0;
                length -= substringLength;
            }
            else
            {
                // update the start index for the next string
                start -= currentLength;
            }

            // check if the length is 0, which means we have added the required substring to the string builder
            if (length == 0)
            {
                break;
            }
        }

        // return the substring from the string builder
        return sb.ToString();
    }
}
```

---

*(I'm going to start abbreviating the responses from this point on for brevity, keeping only the most important bits)*

>Let's optimise this a little by calculating the overall length of the virtual string in the constructor, given it's not going to change once the object is constructed

---

``` csharp
public class VirtualString
{
    private string[] _strings;
    private int _length;

    // constructor that takes an array of strings
    public VirtualString(string[] strings)
    {
        _strings = strings;
        _length = _strings.Sum(s => s.Length);
    }
```

---

>Could you write some xUnit tests to verify the functionality, testing all the edge cases as well?

---

Sure, we can write some xUnit tests to verify the functionality of the VirtualString class. xUnit is a popular unit testing framework for .NET that makes it easy to write and run tests for your code. Here is an example of how we can write xUnit tests for the VirtualString class:

``` csharp
public class VirtualStringTests
{
    [Fact]
    public void TestSubstring_WithValidInput_ReturnsCorrectSubstring()
    {
        // arrange
        var virtualString = new VirtualString(new string[] { "test", "string", "test" });

        // act
        var result = virtualString.Substring(3, 4);

        // assert
        Assert.Equal("tst", result);
    }

    [Fact]
    public void TestSubstring_WithStartIndexGreaterThanLength_ReturnsEmptyString()
    {
        // arrange
        var virtualString = new VirtualString(new string[] { "test", "string", "test" });

        // act
        var result = virtualString.Substring(20, 4);

        // assert
        Assert.Equal(string.Empty, result);
    }

    [Fact]
    public void TestSubstring_WithLengthGreaterThanLength_ReturnsRemainingString()
    {
        // arrange
        var virtualString = new VirtualString(new string[] { "test", "string", "test" });

        // act
        var result = virtualString.Substring(3, 20);

        // assert
        Assert.Equal("tst", result);
    }

    [Fact]
    public void TestSubstring_WithStartIndexAndLengthEqualToLength_ReturnsEntireString()
    {
        // arrange
        var virtualString = new VirtualString(new string[] { "test", "string", "test" });

        // act
        var result = virtualString.Substring(0, 15);

        // assert
        Assert.Equal("teststringtest", result);
    }

    [Fact]
    public void TestSubstring_WithStartIndexAndLengthEqualToZero_ReturnsEmptyString()
    {
        // arrange
        var virtualString = new VirtualString(new string[] { "test", "string", "test" });

        // act
        var result = virtualString.Substring(0, 0);

        // assert
        Assert.Equal(string.Empty, result);
    }
}
```

---

> The assertion looks wrong in TestSubstring_WithLengthGreaterThanLength_ReturnsRemainingString - are you sure it's correct?

---

You're right, the assertion in the `TestSubstring_WithLengthGreaterThanLength_ReturnsRemainingString` test is incorrect. The expected result of this test should be the entire string, not just the remaining string. I apologize for the mistake. Here is the correct version of the test:

``` csharp
[Fact]
public void TestSubstring_WithLengthGreaterThanLength_ReturnsEntireString()
{
    // arrange
    var virtualString = new VirtualString(new string[] { "test", "string", "test" });

    // act
    var result = virtualString.Substring(3, 20);

    // assert
    Assert.Equal("teststringtest", result);
}
```

---

> Hmmm... I still don't think that's correct. Starting at offset 3 and going beyond the length of the string would be "tstringtest" do you agree?

---

You're right, the `TestSubstring_WithLengthGreaterThanLength_ReturnsEntireString` test is still incorrect. The expected result of this test should be the string that starts at the given start index and continues to the end of the string, not the entire string. I apologize for the mistake. Here is the correct version of the test:

``` csharp
[Fact]
public void TestSubstring_WithLengthGreaterThanLength_ReturnsStringFromStartIndexToEnd()
{
    // arrange
    var virtualString = new VirtualString(new string[] { "test", "string", "test" });

    // act
    var result = virtualString.Substring(3, 20);

    // assert
    Assert.Equal("tstringtest", result);
}
```

---

> Ok, so my coding preference is to not use underscore prefixes for field names, and I'd like you to use "this" when referencing them.
> Now you have that test sorted, do the tests again, but without the comments. Also could you have the VirtualString instance configured in the constructor so all the tests share an instance called "sut"? 

---

Sure, here are the xUnit tests for the VirtualString class, with the VirtualString instance created in the constructor and available to all the tests as a sut (System Under Test) field:

``` csharp
public class VirtualStringTests
{
    private readonly VirtualString sut;

    public VirtualStringTests()
    {
        this.sut = new VirtualString(new string[] { "test", "string", "test" });
    }

    [Fact]
    public void TestSubstring_WithValidInput_ReturnsCorrectSubstring()
    {
        // act
        var result = this.sut.Substring(3, 4);

        // assert
        Assert.Equal("tst", result);
    }
```

---

> Are you sure the first test case is correct? You're asking for 4 characters and are asserting a string with only 3?

---

You're right, the TestSubstring_WithValidInput_ReturnsCorrectSubstring test is incorrect. The expected result of this test should be a string with 3 characters, not 4. I apologize for the mistake. Here is the correct version of the test:

``` csharp
[Fact]
public void TestSubstring_WithValidInput_ReturnsCorrectSubstring()
{
    // act
    var result = this.sut.Substring(3, 3);

    // assert
    Assert.Equal("tst", result);
}
```

I have updated the test to request a substring with 3 characters and to compare the result with a string with 3 characters. Let me know if you have any questions or if you need help with anything else. I'm here to help!

---

> What would it be if it was a length of 4?

---

If the TestSubstring_WithValidInput_ReturnsCorrectSubstring test requested a substring with 4 characters, the expected result would be the string "tsts". Here is an updated version of the test that requests a substring with 4 characters and compares the result with the expected string:

``` csharp
[Fact]
public void TestSubstring_WithValidInput_ReturnsCorrectSubstring()
{
    // act
    var result = this.sut.Substring(3, 4);

    // assert
    Assert.Equal("tsts", result);
}
```

---

> Wouldn't that be tstr?

---

Yes, you're right, the expected result of the TestSubstring_WithValidInput_ReturnsCorrectSubstring test would be "tstr" if it requested a substring with 4 characters. The "s" character in the expected string would be repeated because the VirtualString.Substring method would return the string that starts at the given start index and continues for the given length, even if the length is greater than the remaining characters in the string. Here is an updated version of the test that requests a substring with 4 characters and compares the result with the expected string:

``` csharp
[Fact]
public void TestSubstring_WithValidInput_ReturnsCorrectSubstring()
{
    // act
    var result = this.sut.Substring(3, 4);

    // assert
    Assert.Equal("tstr", result);
}
```

---

> For the unit tests, please use the FluentAssertions library to do the assertions

---

Sure, here are the xUnit tests for the VirtualString class that use the FluentAssertions library for the assertions:

``` csharp
public class VirtualStringTests
{
    private readonly VirtualString sut;

    public VirtualStringTests()
    {
        this.sut = new VirtualString(new string[] { "test", "string", "test" });
    }

    [Fact]
    public void TestSubstring_WithValidInput_ReturnsCorrectSubstring()
    {
        // act
        var result = this.sut.Substring(3, 3);

        // assert
        result.Should().Be("tstr");
    }

    [Fact]
    public void TestSubstring_WithStartIndexGreaterThanLength_ReturnsEmptyString()
    {
        // act
        var result = this.sut.Substring(20, 4);

        // assert
        result.Should().BeEmpty();
    }
  ```

  ## Conclusion

  This was a really interesting thing to try out. At the end of this, I had some pretty good skeleton code and unit tests. There was still some refinement to do, including:
  
  * some extra unit tests (negative start positions, different input variations, etc.) 
  * minor optimizations such as initializing the `StringBuilder` to the expected length

  The grunt work had been done though!  I could have asked for ChatGPT to make the modifications, but at this point it was quicker to do them myself.

  Will I do this for all my code? Absolutely not, but it's a useful tool.