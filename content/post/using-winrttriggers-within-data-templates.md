---
title: "Using WinRTTriggers within data templates"
date: "2012-11-03T13:14:12.0000000"
author: "Mike Goatly"
---
[Kaki104 recently commented](/triggers-in-winrt-xaml#comments) that they were having a problem using triggers in a certain situation\. Helpfully a simple repro was provided – a simple grid view\, with an attempt to start a storyboard when an item is clicked:

![image](http://www.goatly.net/Media/Default/Windows-Live-Writer/ab3082f74259_A766/image_3.png)

The trigger had been placed within the data template of the item:

``` xml
<DataTemplate x:Key="DataTemplate1">
    <Grid HorizontalAlignment="Left" Width="250" Height="250">
        <Grid.Resources>
            <Storyboard x:Key="storyboard1">
                <ColorAnimationUsingKeyFrames Storyboard.TargetProperty="(Border.Background).(SolidColorBrush.Color)" Storyboard.TargetName="border">
                    <EasingColorKeyFrame KeyTime="0" Value="#FFB8B5B5"/>
                    <EasingColorKeyFrame KeyTime="0:0:1" Value="#FF3C3B3B"/>
                </ColorAnimationUsingKeyFrames>
                <ColorAnimationUsingKeyFrames Storyboard.TargetProperty="(Panel.Background).(SolidColorBrush.Color)" Storyboard.TargetName="stackPanel">
                    <EasingColorKeyFrame KeyTime="0" Value="#A69C5151"/>
                    <EasingColorKeyFrame KeyTime="0:0:1" Value="#A6F9F3F3"/>
                </ColorAnimationUsingKeyFrames>
            </Storyboard>
        </Grid.Resources>

        <t:Interactions.Triggers>
            <t:PropertyChangedTrigger Binding="{Binding Title}">
                <t:ControlStoryboardAction Action="Start" Storyboard="{StaticResource storyboard1}"/>
            </t:PropertyChangedTrigger>
        </t:Interactions.Triggers>

        <Border x:Name="border" Background="#FF3D3D3D"/>
        <StackPanel x:Name="stackPanel" VerticalAlignment="Bottom" Background="#A6000000">
            <TextBlock Text="{Binding Title}" Foreground="{StaticResource ListViewItemOverlayForegroundThemeBrush}" Style="{StaticResource TitleTextStyle}" Height="60" Margin="15,0,15,0" LayoutUpdated="TextBlock_LayoutUpdated_1" SelectionChanged="TextBlock_SelectionChanged_1"/>
            <TextBlock Text="{Binding Subtitle}" Foreground="{StaticResource ListViewItemOverlaySecondaryForegroundThemeBrush}" Style="{StaticResource CaptionTextStyle}" TextWrapping="NoWrap" Margin="15,0,15,10"/>
        </StackPanel>
    </Grid>
</DataTemplate>
```
Interestingly the designer complains that there is an “illegal qualified name character” in the XAML\, but when you run the code\, everything works as expected\. 

![image](http://www.goatly.net/Media/Default/Windows-Live-Writer/ab3082f74259_A766/image_2d24f464-d558-4608-8bcc-4cf23df0dc24.png)

Now\, I’ve dug around a little and haven’t been able to work out why this is – debugging the host Visual Studio instance doesn’t reveal any exceptions being thrown\, so I can only assume the parser is misreporting a problem\, though in my experience it’s usually something I’m doing that’s wrong\. If anyone can reveal what that is\, I’d be very grateful\!

A simple workaround for this is to just move the contents of the grid into a separate UserControl and reference that from within the DataTemplate instead:

``` xml
<DataTemplate x:Key="DataTemplate1">
    <local:ItemUserControl />
</DataTemplate>
```
This way you don’t get designer errors and everything works at run time\.

I’ve uploaded the [sample code for this here](/Media/Default/Samples/DataTemplateWinRTSample.zip)\, if you’re interested\.

