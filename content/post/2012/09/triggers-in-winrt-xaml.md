---
title: "Triggers in WinRT XAML"
date: "2012-09-28T16:04:00.0000000"
author: "Mike Goatly"
---

> All the code for WinRTTriggers is available from the [CodePlex project site](https://winrttriggers.codeplex.com/)\, and is available in binary form in a [nuget package](https://nuget.org/packages/WinRTTriggers)\.
> 
> 

A few months ago I attended one of Microsoft's "Windows Phone to Windows 8 App" events\. The intent was to take [Equazor](http://www.goatly.net/equazor)and migrate it to a Windows Store application as much as possible over the space of two days\.

On the whole\, the event was really useful to just hang out with a bunch of other developers \(along with some Microsofties like [Mike Taulty](http://mtaulty.com/) and [Martin Beeby](http://blogs.msdn.com/b/thebeebs/)\) and I managed to port all the "business logic" of the app pretty successfully \- you would expect so given that I had used the MVVM pattern with [MvvmLight](http://mvvmlight.codeplex.com/)\, which is now available for WinRT XAML applications\.

Where I became unstuck\, however\, was my reliance on Expression Blend's triggers to manipulate the UI in response to the changing view model and handle the player's interactions; as it turns out these are not currently supported by in the WinRT XAML world\.

*So what's a was I to do\, but write my own implementation?*

## Introducing WinRTTriggers

The best way to explain the sort of things you can do with WinRTTriggers is to show a quick snippet of XAML from the test app that’s available in the solution:

```
<Grid Background="{StaticResource ApplicationPageBackgroundThemeBrush}" 
        DataContext="{StaticResource ViewModel}">
    <Triggers:Interactions.Triggers>
        <Triggers:PropertyChangedTrigger Binding="{Binding Person.Name}">
            <Triggers:ControlStoryboardAction Action="Start" 
                Storyboard="{StaticResource FlashNameChanged}" />
        </Triggers:PropertyChangedTrigger>
        ...
        <Triggers:PropertySetTrigger Binding="{Binding Person.IsHappy}" 
                RequiredValue="false">
            <Triggers:GotoStateAction StateName="Sad" />
        </Triggers:PropertySetTrigger>
    </Triggers:Interactions.Triggers>

    <VisualStateManager.VisualStateGroups>
        <VisualStateGroup x:Name="HappySad">
            <VisualStateGroup.Transitions>
```
There are 2 triggers demonstrated above:

- The first watches the **Person\.Name** property – when it is modified\, it reacts by starting the **FlashNameChanged**storyboard\.
- The second watches the **Person\.IsHappy** property – when it gets set to **false**\, it reacts by changing the visual state to **Sad**\.

From this it should be relatively obvious that there’s a very simple trigger/action relationship going on here – you configure a trigger and specify the action that should happen as a result of it firing\.

### Triggers

Currently implemented are:

- PropertyChangedTrigger \- fires when a property changes to any value
- PropertySetTrigger \- like PropertyChangedTrigger\, except it will only get fire when a property changes to a specified value\.
- EventTrigger \- fires when an event associated to the control is fired\, e\.g\. the Tapped event on a control\. 

### Actions

The current actions are:

- GotoStateAction \- Instructs the VisualStateManager to change to a named state
- InvokeCommandAction \- Invokes some ICommand implementation\, probably located on your view model\.
- ControlStoryboardAction \- Starts/Stops/Pauses a storyboard\.

## Todo…

There are some things that I know are missing\, I definitely haven't covered all the triggers and that Expression did \- I imagine these will be added over time\.

Another big omission is the inability to apply conditions to triggers\, i\.e\. only fire this trigger is some arbitrary value is true\. I may \(or may not\) tackle these soon\, depending on how much I need them\!

## Summary

I still haven’t got the Equazor port done yet\, but I’ve had fun getting this framework up and running over some \(very\) limited free time\. I think that even with just these few triggers I think you'll be able to replicate a reasonable amount of the old Blend interaction logic\.

Let me know if you encounter any problems or have any requests\.

