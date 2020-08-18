---
title: "StoryboardCompletedTrigger and SetPropertyAction"
date: "2013-03-21T20:31:59.0000000"
author: "Mike Goatly"
---
I’ve spent a couple of hours on WinRTTriggers tonight and added a couple of features that have been requested recently\, StoryboardCompletedTrigger and SetPropertyAction\.

## StoryboardCompletedTrigger 

This trigger allows to to fire an action when a storyboard completes – you can use it like this:

``` xml
<Triggers:StoryboardCompletedTrigger Storyboard="{StaticResource FlashNameChanged}">
    <!-- insert your action(s) here -->
</Triggers:StoryboardCompletedTrigger>
```
## SetPropertyAction

This allows you to react to a trigger by setting a property on an object – most likely your view model:

``` xml
<Triggers:Interactions.Triggers>
    <Triggers:PropertyChangedTrigger Binding="{Binding Person.Name}">
        <Triggers:SetPropertyAction Target="{Binding}" 
                                    PropertyName="HasChangedName" Value="true" />
    </Triggers:PropertyChangedTrigger>
</Triggers:Interactions.Triggers>
```
There’s nothing stopping you binding the new value to something another property on your view model\, either:

``` xml
<Triggers:Interactions.Triggers>
    <Triggers:PropertyChangedTrigger Binding="{Binding Person.Name}">
        <Triggers:SetPropertyAction Target="{Binding}" 
                          PropertyName="ChangeCount" 
                          Value="{Binding NextChangeCount}" />
    </Triggers:PropertyChangedTrigger>
</Triggers:Interactions.Triggers>
```
Of course you can combine these with all the other triggers and actions in the WinRTTriggers library in a variety of ways – hopefully these plug a couple of gaps that people have needed filled\!

Hope this helps \- I’m always interested in hearing how you get on with using WinRTTriggers in your Windows 8 applications\!

