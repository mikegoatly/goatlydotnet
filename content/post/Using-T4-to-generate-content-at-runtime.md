---
title: "Using T4 to generate content at runtime"
date: "2010-11-19T00:00:00.0000000"
author: "Mike Goatly"
---
**UPDATE 9 April 2014: The source is also available on [GitHub](https://github.com/mikegoatly/T4TemplateSample)**** **

[T4 \(the **T**ext **T**emplate **T**ransformation **T**oolkit\)](http://en.wikipedia.org/wiki/Text_Template_Transformation_Toolkit) is slowly becoming more widely known as a way to generate code to be compiled and used alongside hand\-written code\. Frameworks such as the Entity Framework V4 have adopted it for its code generation\, allowing you to simply switch out the default class template for an alternative\, e\.g\. POCO entity classes\.

Whilst it seems to be fairly well known that T4 can be used to generate output at design time\, it is less well known that you can actually use a T4 template *at runtime* as well\. An example where you might want to do this is the generation of email content \- this article will demonstrate how you might go about this\.

### Getting set up

*If you want to skip to the end\, the final code can be [downloaded here](/Media/Default/media/686/customeremailtemplate.zip)\.*

First up\, create a new console application\, and add a very simple Customer class \(we need to have someone to generate an email for\, after all\!\):

![image](/images/post/Windows-Live-Writer_Using-T4_1313E_image_thumb.png)

Customer is defined as:

``` csharp
public class Customer
{
    public string Name { get; set; }
    public DateTime LastLoginDate { get; set; }
}
```
Now add a new **Preprocessed Text Template**\, calling it **CustomerEmailTemplate\.tt**\.

![image](/images/post/Windows-Live-Writer_Using-T4_1313E_image_thumb_4.png)

You'll see a new editor looking something like this: \(Note that I'm using Tangible Engineering's excellent [T4 editor extension](http://t4-editor.tangible-engineering.com/T4-Editor-Visual-T4-Editing.html)\, which is why the code is highlighted nicely\)

![image](/images/post/Windows-Live-Writer_Using-T4_1313E_image_thumb_5.png)

### Writing the template

Now we have a template file\, lets add some content: *\(For simplicity we'll generate a plain text email\, although there is absolutely nothing stopping you from generating HTML \- it's still only text after all\.\)*

``` csharp
<#@ template language="C#" #>
<#@ parameter
 name="Customer"
    type="ConsoleApplication1.Customer" #>

Hi <#= Customer.Name #>,

Thanks for logging onto our application on <#=
 Customer.LastLoginDate.ToString("d MMMM yyyy") #>!

Please be sure to come back again soon!

The Email Generation Co.
```
If you've used ASP\.NET this should look fairly familiar\, except in place of <% %> tags we have <\# \#>\. The **<\#@ parameter \#>** declaration\, as you might have guessed\, is how we are going to pass information into a template\. It has to be given a name\, which is referenced later on in the template\, and a type\.

### Using the template

Using the template is almost as easy as writing it \- you can get output in 3 steps:

1. Create a new instance of the template
1. Set the template parameters by configuring then initializing the session
1. Calling TransformText\.

In the Main method in Program\.cs\, add the following code:

``` csharp
var customer = new Customer
{
    Name = "Jeffery",
    LastLoginDate = new DateTime(2009, 11, 2, 19, 23, 32)
};

var template = new CustomerEmailTemplate();
template.Session = new Dictionary<string, object>()
{
    { "Customer", customer }
};

template.Initialize();
Console.WriteLine(template.TransformText());
```
The Session object is just a dictionary of name\-value pairs\. Once the Session has been set\, you must call Initialize\, otherwise you'll get an error calling TransformText\.

If you run the code you should hopefully see this output:

![image](/images/post/Windows-Live-Writer_Using-T4_1313E_image_thumb_6.png)

### That's all folks

One of the things I really like about pre\-processed text templates is that you don't have to add any additional references to your code \(Visual Studio or otherwise\) \- they are completely self contained\. If you're interested in exactly they're doing\, have a look at the generated **CustomerEmailTemplate\.cs** file\. As a side\-note\, if you're having problems structuring your code and things aren't compiling\, I have found that it's sometimes useful to have a peek inside the generated file to see exactly what's being put there \- a misplaced brace is sometimes easier to spot there\.

Whilst this was clearly a very simple and contrived example\, hopefully you get the idea that T4 can be a very powerful tool at run\-time as well as design\-time\.

