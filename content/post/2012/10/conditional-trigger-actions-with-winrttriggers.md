---
title: "Conditional trigger actions with WinRTTriggers"
date: "2012-10-07T20:23:43.0000000"
author: "Mike Goatly"
---

> WinRTTriggers is a available from the [codeplex project site](http://winrttriggers.codeplex.com/) or from [nuget](https://nuget.org/packages/WinRTTriggers)\.
> 
> 

> Sample code for this post can be [downloaded here](/Media/Default/Samples/ConditionalActionSample.zip)\.
> 
> 

The latest update to WinRTTriggers \(v1\.1\.0\) includes 2 big changes:

- Multiple actions can be specified against a trigger  
- An action can have conditions associated to it

The first point is fairly self explanatory\, but the second deserves a bit more elaboration\.

Take the situation where on the first use of your application you want to introduce the user to certain features using a storyboard animation\. In the view model you might have some flag to indicate “first use”:

``` csharp
public class SampleViewModel : ViewModelBase
{
    private bool isFirstUse;

    public bool IsFirstUse
    {
        get { return this.isFirstUse; }
        set
        {
            if (this.isFirstUse != value)
            {
                this.isFirstUse = value;
                this.OnPropertyChanged();
            }
        }
    }
}
```
In your page\, you include the view model as a resource and databind it to the page:

```
<Page
    x:Class="ConditionalActionSample.MainPage"
    xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation"
    xmlns:x="http://schemas.microsoft.com/winfx/2006/xaml"
    xmlns:local="using:ConditionalActionSample"
    xmlns:d="http://schemas.microsoft.com/expression/blend/2008"
    xmlns:mc="http://schemas.openxmlformats.org/markup-compatibility/2006"
    mc:Ignorable="d"
    xmlns:Triggers="using:WinRT.Triggers">
    
    <Page.Resources>
        <local:SampleViewModel x:Name="ViewModel">
            <local:SampleViewModel.IsFirstUse>True</local:SampleViewModel.IsFirstUse>
        </local:SampleViewModel>
    </Page.Resources>
    
    <Page.DataContext>
        <Binding Source="{StaticResource ViewModel}" />
    </Page.DataContext>
```
The content of the page is really simple – just a “magic” button and some introductory text that is initially hidden by setting the opacity to 0:

```
    <Grid Background="{StaticResource ApplicationPageBackgroundThemeBrush}">
        <Button x:Name="magicButton" Content="Click for magic..." />
        <Border x:Name="border" Opacity="0" CornerRadius="500" BorderThickness="3" Background="#FF9FB292" BorderBrush="#FF162314" Margin="152,239,-510,239" Padding="20,0,478,0" RenderTransformOrigin="0.5,0.5">
            <TextBlock FontSize="34.667" TextWrapping="Wrap" Foreground="#FF266C05" TextAlignment="Center" VerticalAlignment="Center" Text="This button is magic. Clicking it performs all sorts of wonderous actions." />
        </Border>
    </Grid>
</Page>
```
Next up\, there’s a storyboard that just flashes the introductory text:

```
    <Page.Resources>
        <local:SampleViewModel x:Name="ViewModel">
            <local:SampleViewModel.IsFirstUse>True</local:SampleViewModel.IsFirstUse>
        </local:SampleViewModel>
        <Storyboard x:Name="FirstLoadStoryboard">
            <DoubleAnimationUsingKeyFrames Storyboard.TargetProperty="(UIElement.Opacity)" Storyboard.TargetName="border">
                <EasingDoubleKeyFrame KeyTime="0:0:1" Value="0"/>
                <EasingDoubleKeyFrame KeyTime="0:0:2" Value="1" >
                	<EasingDoubleKeyFrame.EasingFunction>
                		<BounceEase Bounces="1"/>
                	</EasingDoubleKeyFrame.EasingFunction>
                </EasingDoubleKeyFrame>
            </DoubleAnimationUsingKeyFrames>
        </Storyboard>
    </Page.Resources>

```
And finally\, the bit that ties it all together\, the triggers on the page:

```
    <Triggers:Interactions.Triggers>
        <Triggers:EventTrigger EventName="Loaded">
            <Triggers:ControlStoryboardAction Storyboard="{StaticResource FirstLoadStoryboard}" Action="Start">
                <Triggers:Condition LeftOperand="{Binding IsFirstUse}" Operator="Equals" RightOperand="True" />
            </Triggers:ControlStoryboardAction>
        </Triggers:EventTrigger>
    </Triggers:Interactions.Triggers>
```
Notice that the Condition element within the ControlStoryboardAction element instructs that it should only fire when the IsFirstUse property equals “True”\.

Running the code in its current state will cause the storyboard to start – if the view model’s IsFirstUse value is changed to False\, the storyboard will not be started when the application loads\.

This is just one example of how you might use a condition on an action – hopefully you’ll find them useful in many other situations\.

