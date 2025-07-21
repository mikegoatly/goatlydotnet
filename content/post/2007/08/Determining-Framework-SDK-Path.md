---
title: "Determining Framework SDK Path"
date: "2007-08-06T00:00:00.0000000"
author: "Mike Goatly"
---
Something I've needed to do a couple of times now is
programmatically work out where the the Framework SDK is installed\.
Each time I have to find an example from an old project\, because I
can never remember exactly how I did it before\, so for posterity
\(and to save me searching again\)\, I'm posting it up here\.

Feel free to use this particular snippet however you want\, but
as usual\, I don't provide any warranties that it fit for purpose\,
etc\, so use it at your own risk\! Note that there's no error
handling for when the SDK is not installed\, so you might want to
add that in if you're intending on using it in a fault\-tolerant
environment\.

``` csharp

private static string sdkLocation;

private static string SdkLocation
{
    get
    {
        if (sdkLocation == null)
        {
            sdkLocation = String.Empty;

            RegistryKey key = Registry.LocalMachine.OpenSubKey(
                 @"SOFTWARE\Microsoft\.NETFramework");
            if (key != null)
            {
                object location = key.GetValue("sdkInstallRoot" +
                     ExecutingFrameworkVersion);
                if (location != null)
                {
                    sdkLocation = Path.Combine(location.ToString(),
                        "Bin");
                }
            }
        }

        return sdkLocation;
    }
}

private static string ExecutingFrameworkVersion
{
    get
    {
        return RuntimeEnvironment.GetSystemVersion().Substring(0, 4);
    }
}
```
