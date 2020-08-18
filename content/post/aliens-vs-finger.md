---
title: "Aliens vs Finger"
date: "2013-02-25T19:09:00.0000000"
author: "Mike Goatly"
---
I've been working on another game for Windows Phone \(7\.5\+\) and the result is [Aliens vs Finger](http://www.windowsphone.com/en-gb/store/app/aliens-vs-finger/02a04b4b-f284-4a6e-a424-33bc25763cc2)\!

![6. MainMenu](http://www.goatly.net/Media/Default/Windows-Live-Writer/Aliens-vs-Finger_10A9F/6.%20MainMenu_c8552d67-fd44-4227-adcb-223a9ef04d07.png)

![1. Game1](http://www.goatly.net/Media/Default/Windows-Live-Writer/Aliens-vs-Finger_10A9F/1.%20Game1_766c17a2-fb1f-4854-9882-b7b509e52b94.png)

Aliens vs Finger is a \(hopefully\!\) fun tap\-'em\-up game where you have to squish the aliens and stop the meteors crossing the screen\, all the while being careful to not hit the friendly spacemen\. Although it's in the market place as a paid app \(the lowest price possible\!\) \- the entire game is available as an ad\-supported trial\, so you've got nothing to lose by giving it a go \- only purchase if you enjoy it\!

For those interested\, some of the technical details are:

- Developed in XNA \- I used this for two reasons:

    - Silverlight probably wasn't going to cut it what I was aiming to achieve and I've experimented with XNA before \- nothing fancy but I had an appreciation for what I was letting myself in for\.
    - I wanted to reach the broadest market possible \- focusing solely on Windows Phone 8 would have limited that \- XNA was the best match for Windows Phone 7\.5\+\.
- The high score tables are stored in Azure Mobile Services\. As I [mentioned previously](http://www.goatly.net/using-azure-mobile-services-from-windows-phone-7-apps)\, I used the [azure\-mobile\-csharp\-sdk](https://github.com/kenegozi/azure-mobile-csharp-sdk)to access the API\. There are some interesting points about how I managed the data there\, and I'll probably write more about that in a separate post\.
- All of the animations from the way that the main menu slides around to the way individual aliens move are based around [easing functions](http://www.robertpenner.com/easing/)\. I used a heavily customised version of [XNATweener](http://xnatweener.codeplex.com/)to manage this\.
- The graphics are all drawn by me; I'm no designer\, but I'm fairly happy with the results\!
- In total I think I spent about one and a half weeks working on it\, but as it was one of many "free time" projects it was more like 4 months elapsed time\.

If you do play it\, let me know what you think\!

