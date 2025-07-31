---
title: "Azure DevOps AzureStaticWebApp: specifying Hugo version" 
date: 2025-06-12
description: "Fixing hugo build errors in Azure DevOps when deploying to Azure Static Web Apps" 
featured: true 
toc: false 
codeMaxLines: 100 
codeLineNumbers: false 
figurePositionShow: true 
categories:
  - Azure DevOps
  - Hugo
  - Azure
  - Static Web Apps
---

I use Azure Static Web Apps in a couple of places, this blog and the [Chordle](https://www.chordle.com) site. While updating the templates they use,
I found that the deployment builds started to break because the included Hugo version was out of date.

The first I fixed up was this blog. I was getting this error:

> template: partials/func/getStylesBundle.html:4:90: executing "partials/func/getStylesBundle.html" at <css>: can't evaluate field Sass in type interface {}

This is deployed using GitHub actions, and I found [this](https://learn.microsoft.com/en-us/azure/static-web-apps/publish-hugo#custom-hugo-version) documentation
helped me resolve it there - I simply had to add the Hugo version as an environment variable to the build task.

```yml
    name: Build and Deploy Job
    env:
      HUGO_VERSION: '0.148.1' 
```

The Chordle site is deployed via Azure DevOps though, and the error I was getting there was:

> error building site: failed to create resource spec: error expanding "/blog/:year/:month/:day/:contentbasename/": permalink ill-formed

The breaking syntax is different due to the use of a completely different template.

The required changes to the task syntax aren't described in the linked article. After a bit of playing
around, I found that it was actually almost identical for the `AzureStaticWebApp@0` task - just add an `env` value for the required `HUGO_VERSION`:

```yml
jobs:
- job: build_and_deploy_job
  displayName: Build and Deploy Job
  condition: or(eq(variables['Build.Reason'], 'Manual'),or(eq(variables['Build.Reason'], 'PullRequest'),eq(variables['Build.Reason'], 'IndividualCI')))
  pool:
    vmImage: ubuntu-latest
  variables:
  - group: Azure-Static-Web-Apps-variable-group
  steps:
  - checkout: self
    submodules: true
  - task: AzureStaticWebApp@0
    env:
      HUGO_VERSION: '0.148.1' # <--------- Add this
    inputs:
      azure_static_web_apps_api_token: $(AZURE_STATIC_WEB_APPS_API_TOKEN)
      app_location: "/" 
      api_location: "" 
      output_location: "public"
```

I hope that helps someone else!
