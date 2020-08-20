---
title: "Blog Rebuild" # Title of the blog post.
date: 2020-08-19T18:47:46+01:00 # Date of post creation.
description: "Goatly.net has been overhauled" # Description used for search engine.
featured: true # Sets if post is a featured post, making appear on the home page side bar.
draft: false # Sets whether to render this page. Draft of true will not be rendered.
toc: true # Controls if a table of contents should be generated for first-level links automatically.
# menu: main
thumbnail: "/images/post/static-web-apps-icon.png" # Sets thumbnail image appearing inside card on homepage.
categories:
  - Blog
tags:
  - blog
  - hugo
  - azure
  - static web apps
---

Like a phoenix from the ashes this blog has been reborn! I thought it might be 
interesting to talk about the new architecture, as well as the process I went through to 
migrate it.

> **TL;DR** I used:
> * Hugo to build the site
> * Azure Static Web App for hosting
> * CloudFlare to deal with the top level domain redirection
> * A custom tool called `html2md` to convert my old HTML content to markdown.

## Objectives

1. **Use a static site generator**. As much as I like CMS', for the frequency at which I post
they are overkill. Not having to maintain server side logic and a database is also a win.
1. **Keep all the old content**, including dealing with redirects.
1. **If possible, use this as an opportunity to try new technologies**

## Static Site Generation

I decided to use [Hugo](https://gohugo.io/), having had some success with it recently while building
the new [LIFTI v2 documentation](https://mikegoatly.github.io/lifti/). I used the [Clarity theme](https://themes.gohugo.io/hugo-clarity/)
with some minor customizations, such as swapping out Google Tag Manager for Application Insights to track page views.
You can have a look around the site's code in the [GitHub repo](https://github.com/mikegoatly/goatlydotnet).

### Migrating Content

If all the content in my old site was in markdown this would have been trivial, unfortunately 
this wasn't the case! A brief history of goatly.net:

* *2004* Born on [Windows Live Spaces](https://en.wikipedia.org/wiki/Windows_Live_Spaces) 
(MSN Spaces at that time?)
* *2010* Windows Live Spaces shuts - Migrated all the content to an Umbraco CMS build
* *2012* Migrated all the content to an Orchard CMS build

The main takeaway here is that at no point in its history did this blog ever have anything
fancy like *markdown*; it was all badly formatted HTML, tables with out proper `thead`, etc. To help
with the conversion process I built a tool called [html2md](https://github.com/mikegoatly/html2md)
that allowed me to:

1. Download and convert the raw HTML of my live site
1. Download any linked images
1. Extract [Front Matter metadata](https://gohugo.io/content-management/front-matter#readout) from the page,
writing it to the header of the converted markdown.

## The new architecture

![New goatly.net architecture:right:inline](/images/post/static-hosting-architecture.jpg)



------------

I initially tried hosting the content in an Azure Storage Static Website, but without
fronting that with a CDN and paying for a load of redirect rules, mapping the old URLs
to the new ones wasn't going to work out.

Instead I opted 