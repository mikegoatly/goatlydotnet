---
title: "Entity Framework Code First: \"The path is not valid. Check the directory for the database\""
date: "2011-06-27T00:00:00.0000000"
author: "Mike Goatly"
---
If you create a new MVC application and try to go down the Code
First with SQL Server Compact route\, you might encounter this error
when you first start the application:

> *The path is not valid\. Check the directory for the
> database\.**\[ Path = …\\WebSample\\App\_Data\\YourDatabase\.sdf
> \]*
> 
> 

This error might be a surprise because by default the code first
approach should create the database for you if it doesn't already
exist\.

Whilst this is true\, what it apparently *won't* do is
create any parent folders that the database will be stored under \-
in this case the **App\_Data** folder\. Adding this
folder is easily accomplished by right\-clicking on your project and
selecting *Add/ASP\.NET Folder/App\_Data*\. Once you've done
this\, everything should work as expected\.

As an aside\, the reason it's getting created in the App\_Data
folder is because that's the default location for "DataDirectory"
in a web application\. You might have seen this mentioned in sample
connection strings like this:

``` csharp

<connectionStrings>
    <add name="MyDataContext" 
        providerName="System.Data.SqlServerCe.4.0" 
        connectionString="Data Source=|DataDirectory|MyDatabase.sdf" />
</connectionStrings>
```
You might get this error even if you're not explicitly
specifying the connection string\, as a very similar connection
string will be used by convention if you don't provide one\.

