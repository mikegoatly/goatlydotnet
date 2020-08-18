---
title: "Collapsing Visual Studio Solution Explorer to Project Definitions"
date: "2008-01-23T00:00:00.0000000"
author: "Mike Goatly"
---
Here's a little macro I've just knocked up that will collapse a
Visual Studio Solution to just its project definitions \- put here
so you can use it too and I have access to it everywhere I
work\!

``` csharp

Sub CollapseToProjects() 
    Dim items As UIHierarchyItems 
    Dim i As Integer 

    ' Get the root Solution node 
    items = DTE.ToolWindows.SolutionExplorer.UIHierarchyItems() 
    If items.Count > 0 Then 
        ' Get a pointer to all the nodes under the solution node 
        items = items.Item(1).UIHierarchyItems() 

        For i = 1 To items.Count 
            ' Recursively collapse any expanded items 
            CollapseItems(items.Item(i).UIHierarchyItems) 
        Next 
    End If 
End Sub 

Private Sub CollapseItems(ByVal items As UIHierarchyItems) 
    Dim i As Integer 

    ' Only mess with the item if it's already expanded 
    If items.Expanded Then 

        ' Recurse into the item to collapse any children 
        For i = 1 To items.Count 
            CollapseItems(items.Item(i).UIHierarchyItems) 
        Next 

        ' Collapse the items 
        items.Expanded = False 
    End If 
End Sub
```
