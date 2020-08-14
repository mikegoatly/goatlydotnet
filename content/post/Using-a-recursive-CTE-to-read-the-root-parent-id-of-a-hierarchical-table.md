---
title: "Using a recursive CTE to read the root parent id of a hierarchical table"
date: "2009-12-08T00:00:00.0000000"
author: "Mike Goatly"
---
*Note that this post could be considered the second part in
my previously incredibly short series of 1 posts: Good Uses for SQL
Server 2005 Common Table Expressions \- previous entries
being:*

- [*Part 1 \- Determining the top and bottom n pieces of information
in a set*](/{localLink:1078})
- [*Part 0 \- Introduction*](/{localLink:1071})

\-\-

Ok\, so the title of the post is a bit of a mouthful \- sorry
about that\. I was asked this as a question today\, and as it had
been a little while since I had looked at CTEs I thought it would
be a good exercise to sit down and work it out\.

Consider the following table\, called **Amoeba**\.
\(Amoebas are useful in this context because they only have one
parent\, as far as I am aware\)

|AmoebaId|ParentAmoebaId|
|-|-|
|1|NULL|
|2|1|
|3|1|
|4|2|
|5|3|
|6|NULL|
|7|6|
|8|7|

The amoebas with id 1 and 6 are "ultimate ancestors"\, as they
don't have a parent\. What we need to do is for any given an
AmoebaId\, find out the AmoebaId of its ultimate ancestor\.

Doing this with a recursive CTE is actually pretty straight
forward:

```

DECLARE @CurrentAmoebaId int, @UltimateAncestorId int
SET @CurrentAmoebaId = 5
;WITH ParentAmoebas (AmoebaId, ParentAmoebaId)
AS
(
    SELECT a.AmoebaId, a.ParentAmoebaId
    FROM Amoebas a
    WHERE p.AmoebaId = @CurrentAmoebaId
    UNION ALL
    -- Perform the recursive join
    SELECT a.AmoebaId, a.ParentAmoebaId
    FROM Amoebas a
        INNER JOIN ParentAmoebas pa ON pa.ParentAmoebaId = a.AmoebaId
)
-- Grab the AmoebaId of the ultimate ancestor
-- this will be the only entry with a null parent id
SELECT @UltimateAncestorId = AmoebaId
FROM ParentAmoebas
WHERE ParentAmoebaId IS NULL
SELECT @UltimateAncestorId
```
The inline comments should explain things in enough detail\, but
essentially the CTE will keep recursing up the page hierarchy\,
setting the @UltimateAmoebaId variable\, until the amoeba without a
amoeba id is found\. At this point @UltimateAmoebaId will be set to
the correct ultimate ancestor id\.

