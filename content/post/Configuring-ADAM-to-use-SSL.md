---
title: "Configuring ADAM to use SSL"
date: "2006-07-13T00:00:00.0000000"
author: "Mike Goatly"
---
I've wasted muchos hours trying to configure ADAM to use SSL
in an attempt to use securely it as a membership provider in
ASP\.NET 2\.0\, and one of the biggest problems was the documentation
I found for it\. The procedures I have managed to find on the
internet are either wholly inadequate or simply incorrect\.I'm posting the process I've documented at LSS so that
hopefully others can get through the whole setup a bit quicker\.
I've repeated the process several times on our QA environment
running Server 2003 R2 and on two installations of XP\, so I'm
fairly confident that things are pretty much correct\.Before I begin\, there are a couple of environment assumptions
that are made:
- The machine ADAM is installed on has access to a Cert
server
- The user who is performing this process has permissions to
create certs on said cert server

Ok\, here's the documented process \- enjoy\!

1. On the ADAM server\, open an MMC console
1. Add a **Certificates** snap\-in\, selecting
**Computer Account** and **Local
Computer** as the options when prompted\.
1. Right click on **Personal** and select
**All Tasks/Request New Certificate…**
1. Leave **Computer** selected\, and click
**Next**
1. Type in **ADAM SSL** as the **Friendly
name** and click **Next**\, then
**Finish**
1. Expand and refresh **Personal/Certificates**
\- there should be an entry with the **FQDN** \(fully
qualified domain name\) of the computer in the list of
certificates\.
1. We need to give the account the ADAM service is running
under \(in this case NETWORK SERVICE\) permissions to read the new
certificate\. In Windows explorer\, navigate to **C:\\Documents
and Settings\\All Users\\Application
Data\\Microsoft\\Crypto\\RSA\\MachineKeys**\. \(You will have to
show hidden files in order to get here\.\)
1. Select the file that has just been created \(you can
identify it by sorting on date\)\, right click and select
**Properties**\.
1. On the **Security** tab\, click
**Add…**
1. Type in **NETWORK SERVICE** and click
**OK**
1. Ensure that the only permission granted to
**NETWORK SERVICE** is **Read** \(i\.e\. not
**Read & Execute**\)
1. Restart the ADAM instance service from the Service
Control Manager mmc\.
1. Test the new SSL connection by:
    1. Start/Run **%windir%\\ADAM\\ldp** \- the ADAM
general administration utility will load up
    1. Select
**Connection>Connect…**
    1. Enter **localhost** as the
**Server**
    1. Enter **636** as the **Port**
and **check** the **SSL**
checkbox
    1. Click **OK**
    1. All being well\, LOTS of text should appear in the window
\- if it hasn't worked\, you'll get less text that contains
information that looks suspiciously like an error
message\.

