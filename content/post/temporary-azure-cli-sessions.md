---
title: "Creating temporary Azure CLI login sessions"
date: 2020-12-07T17:16:21Z 
description: "Creating a temporary "
featured: true 
draft: false 
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

The [Azure CLI](https://learn.microsoft.com/en-us/cli/azure/) is my preferred way of working with Azure from the command line - I just love the 
discoverability of the commands. `az --help` is always a great reminder of the root commands and I can keep applying `--help` as I work my down
the various levels - it's much easier to remember than all the various Az PowerShell commands.

You always start with an `az login` to sign into Azure, but there may be times you need to temporarily connect as another user account to the 
same subscription. If you use `az login` again and connect to the same subscription, you're effectively signing out the previous account and
there's no way to switch back to the original account without going through another `az login`.

I ran into this issue recently because I needed to temporarily sign in as an Azure service principal to perform an action, and then silently
switch back to the original user's context.

The Azure CLI allows you to control where its configuration folder is stored using the `AZURE_CONFIG_DIR` environment
variable, and using this knowledge, I came up with this solution - feel free to use or adapt it to your needs.

``` powershell
try {
    # Temporarily point the Azure CLI's token store to a temporary location so we don't sign
    # out the currently logged in user
    $env:AZURE_CONFIG_DIR = "authtemp"

    az login --service-principal -u $AppId -p $Secret -t $TenantId | Out-Null
    if (!$?) {
        [Console]::ResetColor()
        throw "Error signing in service principal $Id"
    }

    # Do whatever you need to do here
}
finally {
    # Remove the temporary token store and switch back to the user
    Remove-Item $env:AZURE_CONFIG_DIR -Recurse -Force
    $env:AZURE_CONFIG_DIR = $null
}
```
