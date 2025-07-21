---
title: "Why have my visual state changes stopped working?"
date: "2012-05-22T00:00:00.0000000"
author: "Mike Goatly"
---
This took me a little while to work out\, and searching for an answer didn't help me out\, so I thought it might be helpful to post this as a pointer to anyone else who encounters the same problem\.

My scenario:

- A Silverlight Windows Phone 7\.1 App
- a control with a number of visual states applied to it
- Interaction triggers that switch between the various states

Everything was working fine until I wrapped the root element of my control in another container element \- all of a sudden the visual states stopped working *at runtime*\. As far as the designer was concerned\, everything was fine though\.

After a bit of digging around I found that the VisualStateManager\.VisualStateGroups element had been moved to the new parent element\, but the VisualStateManager\.CustomVisualStateManager element that Expression Blend had added in to provide smooth animation and layout had not\. Moving the CustomVisualStateManager element to be contained in the root element fixed the problem\.

Hope that helps someone\.

