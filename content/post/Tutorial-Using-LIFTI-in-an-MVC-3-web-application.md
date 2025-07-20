---
title: "Tutorial: Using LIFTI in an MVC 3 web application"
date: "2011-07-01T00:00:00.0000000"
author: "Mike Goatly"
---
*Updated 25/02/2012 \- it was highlighted that some of the
seach phrases used towards the end of this article were not
returning the expected results \- that was down to me making
assumptions about which words would be stemmed \- these examples
have been updated\.*

This tutorial will take you through an end\-to\-end implementation
of a simple web site to manage a list of employees\. LIFTI will be
used to perform full text searching of plain text information
associated to the employees\.

Whilst the site will be built upon MVC 3\, Entity Framework Code
First and Ninject\, the use of these technologies is largely
arbitrary \- you should be able to switch them out for any other
appropriate frameworks\.

> Important: This tutorial relies on you having [nuget](http://nuget.org/) installed \-
> trust me\, it makes the process of setting up your project
> dependencies *so* much easier\.
> 
> 

## Getting started

To get started\, create a new empty MVC 3 application so you have
a basic structure for the web application to be built from\.

[![image](/images/post/Windows-Live-Writer_Using-LIFTI-in-an-MVC-3-web-application_9CFE_image_thumb_1.png)](/images/post/Windows-Live-Writer_Using-LIFTI-in-an-MVC-3-web-application_9CFE_image_4.png)

[![image](/images/post/Windows-Live-Writer_Using-LIFTI-in-an-MVC-3-web-application_9CFE_image_thumb_2.png)](/images/post/Windows-Live-Writer_Using-LIFTI-in-an-MVC-3-web-application_9CFE_image_6.png)

Now use [nuget](http://nuget.org/) to
add LIFTI \- open the **Package Manager Console**
\(View/Other Windows/Package Manager Console\) and type:

```

Install-Package LIFTI
```
The LIFTI assembly will be downloaded and added as a reference
to your project\.

Install the EntityFramework\.SqlServerCompact and Ninject\.MVC3
packages using the package manager:

```

Install-Package EntityFramework.SqlServerCompact
Install-Package Ninject.MVC3
```
Adding these packages will automatically pull through all these
packages \(some of them are the dependencies of the two you
added\):

- EntityFramework
- WebActivator
- SqlServerCompact
- EntityFramework\.SqlServerCompact
- Ninject
- Ninject\.MVC3

Both Ninject\.MVC3 and EntityFramework\.SqlServerCompact packages
add code files into a folder called App\_Start\. The SqlServerCompact
class configures the default connection factory for the entity
framework library to use the SQL Server Compact connection factory;
the NinjectMVC3 class allows you to configure your dependency
injection \- you'll come onto that later\.

## Create a model and data context

Add Employee\.cs to the Models folder of the project
containing:

``` csharp

public class Employee
{
    [Key]
    public int EmployeeId { get; set; }

    [StringLength(100), Required]
    public string Name { get; set; }

    [Required]
    public DateTime DateOfEmployment { get; set; }

    public string Notes { get; set; } 
}
```
Add EmployeeDataContext\.cs to the Models folder:

``` csharp

public class EmployeeDataContext : DbContext
{
    public DbSet<Employee> Employees
    {
        get;
        set;
    }
}
```
## Scaffold out the site

Make sure that you have built the project and right\-click on the
Controllers folder\, selecting **Add Controller…**:

- Name the controller EmployeesController
- Make sure the template "Controller with read/write actions and
views…" is selected
- Select Employee as the model
- Select EmployeeDataContext as the data context
- Press Add

The scaffolded actions and views will be created for you \(very
handy in tutorials like this\!\)\.

Before you run the project\, [make sure you have added the App\_Data ASP\.NET
folder](/2011/6/27/entity-framework-code-first-the-path-is-not-valid-check-the-directory-for-the-database.aspx) to the project by right clicking on the project and
selecting Add > Add ASP\.NET Folder > App\_Data\.

At this point you should be able to run the project to make sure
that everything you've done so far is correct\. You should be able
to fire up the project and navigate to
*http://localhost:xxxx/Employees* where xxxx is the port
number for your project:

[![image](/images/post/Windows-Live-Writer_Using-LIFTI-in-an-MVC-3-web-application_9CFE_image_thumb_4.png)](/images/post/Windows-Live-Writer_Using-LIFTI-in-an-MVC-3-web-application_9CFE_image_10.png)

Ok\, so it doesn't look very sexy\, but it's a website with a SQL
Server Compact database sitting behind it\, all up and running in
just a few steps\.

## Introducing LIFTI

The full text index that you will be using is an updatable full
text index that will contain the IDs of employees indexed against
the text in their notes\. More specifically\, this will be an
instance of PersistedFullTextIndex<int> \- this type of index
is backed by a file store\, which means that if the web application
is stopped and started\, the index will not lose all its data and
will be able to pick up where it left off\. Significantly this means
that you will be able to keep the index and database in sync\,
assuming that whenever the database is updated you also update the
index\.

Under most circumstances there should only ever be one instance
of your index in memory\. This means that all of your code\, whatever
thread it is on\, should interact with the same index \(don't worry\,
LIFTI's implementation of the full text index is thread safe\.\)\. You
could implement this is any number of ways:

- Using the singleton pattern
- Storing the index in a static variable somewhere that can be
access by the depending code
- Storing the index in Application state
- Using dependency injection to provide one common index to any
depending code

Like all good developers these days\, I'm sure you'll want to
take the dependency injection route\! The first step to this is to
add your index into the dependency injection framework\.

Open App\_Start\\NinjectMVC3\.cs and change the RegisterServices
method so it looks like this:

``` csharp

private static void RegisterServices(IKernel kernel)
{
    string filePath = Path.Combine(
        (string)AppDomain.CurrentDomain.GetData("DataDirectory"), 
        "Index.dat");

    kernel.Bind<IUpdatableFullTextIndex<int>>()
        .To<PersistedFullTextIndex<int>>()
        .InSingletonScope()
        .WithConstructorArgument("backingFilePath", filePath)
        .OnActivation((IUpdatableFullTextIndex<int> i) =>
        {
            i.WordSplitter = new StemmingWordSplitter();
            i.QueryParser = new LiftiQueryParser();
        });
}
```
The **filePath** variable is configured so that the
index data file \(index\.dat\) will be stored in the App\_Data folder
for the application\. \(that's where "DataDirectory" points by
default in a web application\.\)

Then the Ninject kernel is instructed that:

- Whenever an instance of IUpdatableFullTextIndex<int> is
requested \(**Bind**\)
- Map it to an instance of PersistedFullTextIndex<int>
\(**To**\)
- And re\-use it globally\, i\.e\. only ever create one instance
\(**InSingletonScope**\)
- When it is constructed\, pass the path to the index data to the
"backingFilePath" parameter
\(**WithConstructorArgument**\)
- And finally\, when it is activated\, set the WordSplitter and
QueryParser properties to instances of [StemmingWordSplitter](http://lifti.codeplex.com/wikipage?title=Word%20splitters&amp;referringTitle=Documentation) and [LiftiQueryParser](http://lifti.codeplex.com/wikipage?title=Searching%20the%20full%20text%20index&amp;referringTitle=Documentation)\, respectively\.
\(**OnActivation**\)

Now you just have to consume the index and use it in the
controller\.

## Updating the index

Open the EmployeesController class and add a constructor:

``` csharp

private IUpdatableFullTextIndex<int> index;
public EmployeesController(IUpdatableFullTextIndex<int> index)
{
    this.index = index;
}
```
Ninject \(in conjunction with the nice dependency resolution in
MVC 3\) will take care of providing your controller with the
relevant instance of the index whenever it is constructed\.

There are 3 places in the controller that you need to interact
with the index to keep it in sync with the database:

- Creating an employee \- the index should be updated if notes are
provided for the employee
- Updating an employee \- the index should be updated if the
employee has notes\, or have any indexed text removed if the
employee no longer has any notes
- Deleting an employee \- any previously indexed notes for the
employee should be removed

Update the HttpPost Create method so it looks like this:

``` csharp

[HttpPost]
public ActionResult Create(Employee employee)
{
    if (ModelState.IsValid)
    {
        db.Employees.Add(employee);
        db.SaveChanges();

     if (!String.IsNullOrEmpty(employee.Notes))
        {
            this.index.Index(employee.EmployeeId, employee.Notes);
        }

        return RedirectToAction("Index");  
    }

    return View(employee);
}
```
Then the HttpPost Edit method:

``` csharp

[HttpPost]
public ActionResult Edit(Employee employee)
{
    if (ModelState.IsValid)
    {
        db.Entry(employee).State = EntityState.Modified;
        db.SaveChanges();

     if (String.IsNullOrEmpty(employee.Notes))
        {
            this.index.Remove(employee.EmployeeId);
        }
        else
        {
            this.index.Index(employee.EmployeeId, employee.Notes);
        }

        return RedirectToAction("Index");
    }
    return View(employee);
}
```
And finally\, the HttpPost Delete method:

``` csharp

[HttpPost, ActionName("Delete")]
public ActionResult DeleteConfirmed(int id)
{            
    Employee employee = db.Employees.Find(id);
    db.Employees.Remove(employee);
    db.SaveChanges();

 this.index.Remove(employee.EmployeeId);

    return RedirectToAction("Index");
}
```
Try the application out again\, you should be able to create\,
update and delete employees without any problems \- the full text
index will be built up in the background\.

## Searching for employees

The last step is to allow users of your site to search for
interesting text within the employee notes\.

Update the Views\\Employees\\index\.cshtml file with a search
textbox just after the <h2> tag:

```

<h2>Index</h2>

@using (Html.BeginForm()) {
<p>
    @Html.Label("searchCriteria", "Search employee notes:")
    @Html.TextBox("searchCriteria") 
    <input type="submit" value="Search" />
</p>
}
```
Now add a new method to the EmployeesController to handle the
posting of the search text:

``` csharp

[HttpPost]
public ViewResult Index(string searchCriteria)
{
    if (String.IsNullOrEmpty(searchCriteria))
    {
        return Index();
    }

    var matchingIds = this.index.Search(searchCriteria).ToArray();
    var employees = this.db.Employees
        .Where(e => matchingIds.Contains(e.EmployeeId))
        .ToList();

    return View(employees);
}
```
*The astute amongst you will notice that the data context
isn't injected in the same way that the index is \- good spot\. This
tutorial is long enough\, so I'll leave that as an exercise for you
to fix up if it's bugging you that much\!*

## Testing the application

Build and run the project create these employees:

|Name|Date of employment|Notes|
|-|-|-|
|Ralph|12/08/2008|Often arriving late to work and frequently takes long lunch breaks|
|Tracy|02/02/2010|New employee\, very diligent worker\, and no\-one is doubting their commitment\, but sometimes acts suspicious when asked about the amount of sick leave taken|
|Bob|23/11/2003|Works long hours\. Arrives early to work and generally stays later than others and works through lunch\. Has a tendency to break the build with a high frequency though\.|
|Andy|10/08/2007|Very clean desk \- there are doubts that he doesn't actually do anything at work|


 Try some of these search criteria on the index page:

### doubts

Andy is obviously matched \- in his notes he has "doubts"
specified exactly\. However there's more going on here because Tracy
is also matched\. This is because you're using the stemming word
splitter process words in the index\, and that automatically removes
some word suffixes\, such as the "s" from "doubts" and "ing" in
Tracy's "doubting" \- this means that when you searched for "doubts"
you were actually searching for anything that stemmed to
"doubt"\.

### emp

Nothing will come back \- not even Tracy\. This is because the
default behaviour for the LIFTI query parser is to match words
exactly\.

### emp\*

Tracy will be returned \- she is the only employee with notes
containing a word that starts with "emp"\.

### lunch & break \(or lunch break\)

Both Ralph and Bob will be returned \- both of these contain
derivatives of "lunch" and "break" in their notes\.

### "lunch break"

Only Ralph contains a phrase that contains "lunch" followed
immediately by a derivative of "break"\.

### … your search criteria here

The LIFTI search engine is quite powerful and there are [loads of different search permutations](http://lifti.codeplex.com/wikipage?title=Searching%20the%20full%20text%20index&amp;referringTitle=Documentation) you
could try out\, so try creating a few more employees and searching
using some of the other operators\, such as or \(|\) or near \(~\)\.

