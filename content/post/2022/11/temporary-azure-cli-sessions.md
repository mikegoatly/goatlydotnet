---
title: "Creating temporary Azure CLI login sessions"
date: "2022-11-01T12:26:21Z" 
description: "Creating a temporary login session with the Azure CLI"
draft: false 
author: "Mike Goatly"
toc: false 
codeMaxLines: 30
categories:
  - Azure
tags:
  - PowerShell
  - Azure
  - Azure CLI
  - Authentication
---

The [Azure CLI](https://learn.microsoft.com/en-us/cli/azure/) is my preferred way of working with Azure from the command line - I love the 
discoverability of the commands. `az --help` is always a great reminder of the root commands and I can keep applying `--help` as I work my down
the various levels - it's much easier to remember than all the various Az PowerShell commands.

You always start with an `az login` to sign into Azure, but there may be times you need to temporarily connect as another account to the 
same subscription. If you use `az login` again, you're effectively signing out the previous account and
there's no way to switch back to the original account without going through another `az login`.

I ran into this issue recently because I needed to temporarily sign in as an Azure service principal to perform an action, and then silently
switch back to the original user's context.

The Azure CLI allows you to control where its configuration folder is stored using the `AZURE_CONFIG_DIR` environment
variable. Using this knowledge I came up with this:

``` powershell
try {
    # Temporarily point the Azure CLI's config to a new location
    $env:AZURE_CONFIG_DIR = "authtemp"

    az login --service-principal -u $AppId -p $Secret -t $TenantId | Out-Null
    if (!$?) {
        [Console]::ResetColor()
        throw "Error signing in service principal $Id"
    }

    # Do whatever you need to do here
}
finally {
    # Remove the temporary config and switch back to the user
    Remove-Item $env:AZURE_CONFIG_DIR -Recurse -Force
    $env:AZURE_CONFIG_DIR = $null
}
```

This does come with a health warning though - by switching over to a new config directory, you are also *temporarily getting rid of any
extensions that you have installed*. After switching back they will be available to you again, but if your script requires
access to an extension during the temporary session, you'll need to remember to install it:

``` powershell
az extension add --upgrade -n <EXTENSIONNAME>
```
