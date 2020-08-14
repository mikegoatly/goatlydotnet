---
title: "Export all tables in an Access database to CSV"
date: "2012-05-29T00:00:00.0000000"
author: "Mike Goatly"
---
I don't usually mess around with Access much\, but when I do it's usually to have it act as an intermediary data source while I'm getting data from one format to another\.

I had just such a problem to solve today\, and the usually excellent out\-of\-the\-box import/export processes let me down a little\. Essentially I needed to get the data from each of the tables into separate CSV files \- unfortunately I had quite a few tables to do and the UI only allows you to do one at a time\.

Here's the little VBA routine I put together to solve the problem:

```
Public Sub ExportAllTablesToCSV()

    Dim i As Integer
    Dim name As String
    
    For i = 0 To CurrentDb.TableDefs.Count
        name = CurrentDb.TableDefs(i).name
        
        If Not Left(name, 4) = "msys" And Not Left(name, 1) = "~" Then
            DoCmd.TransferText acExportDelim, , name, _
                "c:\exports\" & name & ".csv", _
                True
        End If
    
    Next i

End Sub
```
