---
title: "Building a debugger visualizer for generic types"
date: "2011-01-31T00:00:00.0000000"
author: "Mike Goatly"
---
***You can find the source code relating to this
post**[**here**](/media/1021/genericdebuggervisualizer.zip)**\.***

Since Visual Studio 2005 we have been able to write debugger
visualizers to help us look at data in a more convenient way whilst
debugging\.

A while ago I needed to write a visualizer for [LIFTI](http://lifti.codeplex.com/) \- the
problem that I had was that the type I wanted to visualize was
generic\, and it's not straightforward to write a visualizer for a
generic type\. I thought it would be useful to explain my approach
to this solution for others to follow\.

Lets start with an example class that we can debug\. It'll be a
generic class containing an item of some type\, and an associated
score\, between 0 and 99\. *\(Yes\, it's contrived\, but it keeps it
simple\!\)*

``` csharp

[DebuggerVisualizer(typeof(ItemScoreDebuggerVisualizer))]
[Serializable]
public class ItemScore<TItem>
{
    public TItem Item { get; set;}
    public int Score { get; set; }
}
```
Note that the class is marked as Serializable\. This is a
requirement of any object that is going to be passed to a debugger
visualizer because the visualizers are hosted in a separate
AppDomain\. Objects have to be migrated from their domain to the
debugger domain\, and this is accomplished using serialization\.

The class is also marked as having a DebuggerVisualizer of type
ItemScoreDebuggerVisualizer\. This is defined as:

``` csharp

public class ItemScoreDebuggerVisualizer : DialogDebuggerVisualizer
{
    protected override void Show(IDialogVisualizerService windowService, 
        IVisualizerObjectProvider objectProvider)
    {
        object rawData = objectProvider.GetObject();
        var objectType = rawData.GetType();
        var method = this.GetType().GetMethod(
            "ShowItemScoreVisualizer", 
            BindingFlags.Instance | BindingFlags.NonPublic);
        method = method.MakeGenericMethod(objectType.GetGenericArguments());
        method.Invoke(this, new object[] { rawData });
    }

    private void ShowItemScoreVisualizer<TItem>(ItemScore<TItem> itemScore)
    {
        var window = new VisualizerWindow();
        window.ShowItemScore(itemScore);
        window.ShowDialog();
    }
}
```
Ok\, this is obviously where the important stuff is\, so let's
break it down\.

The **Show** method is called by Visual Studio in
order to display the visualizer:

1. Get the object being visualized from the provided
IVisualizerObjectProvider instance\. Note that this is returned as
an instance of type **System\.Object** \- we don't know
what generic type is being used at this point\.
1. We get the type information for the visualized object\.
1. We get the method information for ShowItemScoreVisualizer\, a
generic method that takes an instance of ItemScore as its
parameter\.
1. At this point in time\, the ShowItemScoreVisualizer method
information doesn't have a concrete type associated to it\, so we
use MakeGenericMethod to build a MethodInfo up with a specific
type\. The key here is that we are passing the generic arguments of
the visualized object type to the MakeGenericMethod call\.
1. We invoke the method\.

The ShowItemScoreVisualizer implementation is very simple \- we
now can refer to itemScore\.Item as we would in any generic method\.
You might want to use generic constraints on your implementation\,
but for this example being able to use ToString is enough\.

I won't go into the implementation of VisualizerWindow as it's
largely irrelevant for this post\. *As a side note\, the
visualizer window is a WPF window\, which is why I'm not calling
IDialogVisualizerService\.ShowDialog\, as this requires an instance
of a classic Windows Form\. I'm not sure how supported this approach
is\, so take that part of the code a pinch of salt\!*

Now when you debug into the code and get hover over a variable
containing an instance of ItemScore\, you'll see the little
magnifying glass next to the variable data:

![image](/images/post/2011/01/Windows-Live-Writer_76320b98df53_9AAB_image_thumb_2.png)

Clicking on the magnifying glass will call into the Show method\,
ultimately resulting in our visualizer window being displayed:

![image](/images/post/2011/01/Windows-Live-Writer_76320b98df53_9AAB_image_thumb_3.png)

As always\, let me know in the comments if you find this
useful\!

