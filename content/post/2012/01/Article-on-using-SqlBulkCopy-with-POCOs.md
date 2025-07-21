---
title: "Article on using SqlBulkCopy with POCOs"
date: "2012-01-20T00:00:00.0000000"
author: "Mike Goatly"
---
I realised that I never pushed this on my blog at all\, so
belatedly I will\.

Last year I wrote an article for Developer Fusion that discussed
how you could make use of SqlBulkCopy to do high performance
inserts when you were working with POCOs\, rather than inserting
them entity by entity using an ORM\.

The bottom line was that inserting 10\,000 records took only 57ms
using the generic SqlBulkCopy approach I describe\, rather than
2159ms to insert them on a record\-by\-record basis\.

You can check the article out here: [Using SqlBulkCopy for high performance
inserts](http://www.developerfusion.com/article/122498/using-sqlbulkcopy-for-high-performance-inserts/)

