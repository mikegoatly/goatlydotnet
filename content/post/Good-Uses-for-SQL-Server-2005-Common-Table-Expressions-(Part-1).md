---
title: "Good Uses for SQL Server 2005 Common Table Expressions (Part 1)"
date: "2008-01-11T00:00:00.0000000"
author: "Mike Goatly"
---
Previous posts in this series:

- [
Part 0 \- Introduction](/{localLink:1071})

### Determining the top and bottom *n* pieces of information
in a set

This scenario involves a set that has a column with both
positive and negative ranges of data\. The requirement is to filter
it such that the only rows returned are those with the 3 highest
positive and 3 lowest negative values \- basically the two
extremes\.

#### The sample data

The data I'll be working with in this example is in a table
called **SampleData**\, which contains:

 

| Key | Value|
|-|-|
|A|45|
|B|89|
|C|\-56|
|D|\-12|
|E|\-8|
|F|94|
|G|\-96|
|I|11|
|J|72|
|K|22|
|L|23|

#### Step 1: Get the data in the right order

Before we touch a CTE\, we need to work out how we can get the
data in priority order\, that is to say\, the most positive and most
negative numbers at the top of the list\. This isn't as simple as
just ordering by Value in ascending or descending order\, because
whichever way we order\, either the negative or positive numbers
will be going in the wrong direction\. A nice solution to this is to
order by the absolute value\, like this:

```
SELECT [Key], [Value]
FROM SampleData
ORDER BYABS([Value])DESC
```
Which returns the data as:

 

| Key | Value |
|-|-|
|G |\-96 |
|F |94 |
|B |89 |
|J |72 |
|C |\-56 |
|A |45 |
|L |23 |
|K |22 |
|D |\-12 |
|I |11 |
|E |\-8 |

As you can see\, although the positive and negative numbers are
all mixed together\, they are in the right order \- from lowest
negatives up and highest positives down\.

#### Step 2: Introduce the CTE magic

There are two things we need to do to the data now it's ordered\,
somehow segregate the positive and negative numbers and select the
most appropriate 3 records of each\.

To start things we'll use the ROW\_NUMBER\(\) ranking function to
provide a rank to each row\, the first row being assigned 1\, then
next 2 and so on:

```
WITH OrderedData AS
(
 SELECT [Key],
        [Value],
     ROW_NUMBER()OVER(
         ORDER BYABS([Value])DESC)AS RankPosition
    FROM SampleData
)
SELECT [Key], [Value], [RankPosition]
FROM OrderedData
```
The ORDER BY clause has moved from the select statement and is
now used to specify the order the records should be ranked\, and the
main select statement forms part of a CTE\. Running this gives us
the following:

 

| Key | Value | RankPosition |
|-|-|-|
|G |\-96 |1 |
|F |94 |2 |
|B |89 |3 |
|J |72 |4 |
|C |\-56 |5 |
|A |45 |6 |
|L |23 |7 |
|K |22 |8 |
|D |\-12 |9 |
|I |11 |10 |
|E |\-8 |11 |

But what we want is the positive numbers and negative numbers
numbered independently\. To do this we can use the windowing clause
PARTITION BY in the ranking statement:

```
WITH OrderedData AS
(
 SELECT [Key],
        [Value],
     ROW_NUMBER()OVER(
         PARTITION BYSIGN([Value])ORDER BYABS([Value])DESC)AS RankPosition
    FROM SampleData
)
SELECT [Key], [Value], [RankPosition]
FROM OrderedData
```
Here we are partitioning by the sign of the Value data\, which
means we now get:

 

| Key | Value| RankPosition|
|-|-|-|
|G|\-96|1|
|C|\-56|2|
|D|\-12|3|
|E|\-8|4|
|F|94|1|
|B|89|2|
|J|72|3|
|A|45|4|
|L|23|5|
|K|22|6|
|I|11|7|

The only thing left to do is make sure that only up to 3 rows
from the positive and negative sets are returned \- this is a really
simple addition:

```
WITH OrderedData AS
(
 SELECT [Key],
        [Value],
     ROW_NUMBER()OVER(
         PARTITION BYSIGN([Value]) 
         ORDER BYABS([Value])DESC)AS RankPosition
    FROM SampleData
)
SELECT [Key], [Value]
FROM OrderedData
WHERERankPosition<=3
```
Which gives us exactly what we were after:

 

| Key | Value|
|-|-|
|G|\-96|
|C|\-56|
|D|\-12|
|F|94|
|B|89|
|J|72|

