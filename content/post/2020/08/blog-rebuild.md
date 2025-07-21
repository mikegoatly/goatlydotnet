---
title: "Blog Rebuild" # Title of the blog post.
date: 2020-08-25T17:27:46+01:00 # Date of post creation.
description: "Goatly.net has been overhauled" # Description used for search engine.
featured: true # Sets if post is a featured post, making appear on the home page side bar.
draft: false # Sets whether to render this page. Draft of true will not be rendered.
toc: true # Controls if a table of contents should be generated for first-level links automatically.
# menu: main
thumbnail: "/images/post/2020/08/static-web-apps-icon.png" # Sets thumbnail image appearing inside card on homepage.
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
>
> * Hugo to build the site
> * Azure Static Web App for hosting
> * CloudFlare to deal with the top level domain redirection
> * A custom tool called `html2md` to convert my old HTML content to markdown.

## Objectives

1. **Use a static site generator**. As much as I like CMS', for the frequency at which I post
they are overkill. Not having to maintain server side logic and a database is also a win.
1. **Keep all the old content**, including dealing with redirects.
1. **If possible, use this as an opportunity to try new technologies**.

## Static Site Generation

![Hugo logo:right:inline](/images/post/2020/08/hugo.png)
I decided to use [Hugo](https://gohugo.io/), having had some success with it recently while building
the new [LIFTI v2 documentation](https://mikegoatly.github.io/lifti/). I used the [Clarity theme](https://themes.gohugo.io/hugo-clarity/)
with some minor customizations, such as swapping out Google Tag Manager for Application Insights to track page views.
You can have a look around the site's code in the [GitHub repo](https://github.com/mikegoatly/goatlydotnet).

There are lots of resources out there on creating a site based on Hugo so I won't go into details here. The
[Hugo Quick Start](https://gohugo.io/getting-started/quick-start/) is a good example.

### Migrating Content With html2md

If all the content in my old site was in markdown this would have been trivial, unfortunately
this wasn't the case - to understand why, here's a potted history of goatly.net:

* *2004* Born on [Windows Live Spaces](https://en.wikipedia.org/wiki/Windows_Live_Spaces)
(MSN Spaces at that time?)
* *2010* Windows Live Spaces shuts - Migrated all the content to an Umbraco CMS build
* *2012* Migrated all the content to an Orchard CMS build

The main takeaway here is that at no point in its history did this blog ever have anything
fancy like *markdown*; it was all badly formatted HTML, tables with out proper `thead`, etc, transformed
multiple times to different platforms. 

To help with the conversion process I built a tool called [html2md](https://github.com/mikegoatly/html2md) that allowed me to:

1. Download and convert the raw HTML of my live site
1. Download any linked images
1. Update image link addresses
1. Extract [Front Matter metadata](https://gohugo.io/content-management/front-matter#readout) from the page,
writing it to the header of the converted markdown.

Publishing `html2md` as a [dotnet tool](https://www.nuget.org/packages/dotnet-html2md/) allowed me to build a
single script to download and process all the content. I used this process to refine the output from `html2md`
as I went. You can still see the [resulting script in the repo](https://github.com/mikegoatly/goatlydotnet/blob/master/loadposts.ps1), but here's a snippet:

``` powershell
$pages = @(
    "2006/7/20/Easy-way-to-enter-GUIDs-for-WiX-scripts.aspx",
    ...
    "fixing-nuget-errors-after-removing-microsoft-bcl-build",
    "using-dynacache-with-simpleinjector"
)

$Urls = @($pages | ForEach-Object { @( "-u", "http://goatly.net/$_") })
$Html2mdArgs = @(
    "-o",
    ".\content\post\",
    "-i",
    ".\static\images\post\",
    "--image-path-prefix",
    "/images/post/"
    "--it",
    "//article[@class='blog-post content-item']",
    "--et",
    "header,//h2[@class='comment-count'],//ul[@class='comments'],//div[@id='comments']",
    "--code-language-class-map",
    "xml:xml,sh_csharp:csharp",
    "--front-matter-data",
    "title://article/header/h1",
    "--front-matter-data",
    "date://div[@class='metadata']/div[@class='published']:Date",
    "--front-matter-data",
    "author:{{'Mike Goatly'}}",
    "--front-matter-data-list",
    "tags://p[@class='tags']/a",
    "--logging",
    "Debug"
)

$Html2mdArgs = $Html2mdArgs + $Urls

& 'html2md.exe' $Html2mdArgs
```

## Hosting

![Azure static web apps logo:right:inline](/images/post/2020/08/static-web-apps-icon.png)
I initially tried hosting the content in an Azure Storage Static Website, but without
fronting that with a CDN and paying for a load of redirect rules, mapping the old URLs
to the new ones wasn't going to work out.

Instead I opted to use the new [Static Web App](https://azure.microsoft.com/en-us/services/app-service/static/) Azure service
that's currently in preview. The benefits from this were:

* Pre-canned deployment process. I just push changes to GitHub and an automatically configured GitHub action
builds the site and publishes it to Azure. 🧙🏾‍♂️🎉
* A really simple way to statically declare server-side redirects using a `routes.json` file:

``` json
{
    "routes":[
        {
            "route": "/2006/7/20/Easy-way-to-enter-GUIDs-for-WiX-scripts.aspx",
            "serve": "/post/easy-way-to-enter-guids-for-wix-scripts",
            "statusCode": 301
        },
        ...
    ]
}
```

## Top level domain handling

![Cloudflare logo:right:inline](/images/post/2020/08/cloudflare-logo.png)
One of the things that Static Web Apps can't currently handle is top level domains (aka naked domains). Previously
my blog was primarily hosted at `https://goatly.net` so I needed a way to redirect traffic from there to the `www`
subdomain. Fortunately there's a [workaround documented](https://burkeholland.github.io/posts/static-app-root-domain/)
that uses CloudFlare to proxy requests for the top level domain and redirect to `www`.

## Summary

That's the journey of how this new iteration of my blog came to being - hopefully there's some interesting pointers
in there for others who want to undertake something similar!
