---
title: 'MSBuildSchemaGen'
noDate: true
---

> MSBuildSchemaGen is no longer available for download. This page is kept for posterity.

MSBuildSchemaGen was a tool that generated MSBuild XSD schema files for custom MSBuild tasks, which allowed the Visual Studio editor to provide tooltips for your custom tasks when you are writing MSBuild scripts.

MSBuildSchemaGen generated its schemas in such a way that it was able to handle tasks that derive from base Task classes, including abstract classes, and could also restrict inputs to parameters that required it by binding them to enumerations.

In addition to schemas, MSBuildSchemaGen also produced a tasks reference file for your assembly, which saved you having to remember the UsingTask statements for your tasks.

## Usage

The [original post](http://www.goatly.net/2008/12/8/Creating-MSBuild-XSD-schemas-for-your-custom-tasks.aspx)
covers a bit more about the tool.

## Example Output

``` xsd
<xs:schema 
    xmlns:msb="http://schemas.microsoft.com/developer/msbuild/2003" 
    elementFormDefault="qualified" 
    targetNamespace="http://schemas.microsoft.com/developer/msbuild/2003" 
    xmlns:xs="http://www.w3.org/2001/XMLSchema">
  <xs:include schemaLocation="MSBuild\Microsoft.Build.Commontypes.xsd" />
  <xs:simpleType name="ColoringType">
    <xs:union memberTypes="msb:non_empty_string">
      <xs:simpleType>
        <xs:restriction base="xs:string">
          <xs:enumeration value="Blue">
            <xs:annotation>
              <xs:documentation>The blue colouring.</xs:documentation>
            </xs:annotation>
          </xs:enumeration>
          <xs:enumeration value="Red">
            <xs:annotation>
              <xs:documentation>The red colouring.</xs:documentation>
            </xs:annotation>
          </xs:enumeration>
        </xs:restriction>
      </xs:simpleType>
    </xs:union>
  </xs:simpleType>
  <xs:complexType name="TestTaskType">
    <xs:complexContent mixed="false">
      <xs:extension base="msb:TaskType">
        <xs:attribute name="Name" type="msb:non_empty_string" use="required">
          <xs:annotation>
            <xs:documentation>Gets or sets the name of the item.</xs:documentation>
          </xs:annotation>
        </xs:attribute>
        <xs:attribute name="Color" type="msb:ColoringType" use="optional">
          <xs:annotation>
            <xs:documentation>[Optional] Gets or sets the color.</xs:documentation>
          </xs:annotation>
        </xs:attribute>
        <xs:attribute name="DisplayType" type="xs:string" use="optional">
          <xs:annotation>
            <xs:documentation>[Optional] [Obsolete] Gets or sets the display type.</xs:documentation>
          </xs:annotation>
        </xs:attribute>
        <xs:attribute name="Result" type="xs:string" use="optional">
          <xs:annotation>
            <xs:documentation>[Optional] [Output] Gets the result.</xs:documentation>
          </xs:annotation>
        </xs:attribute>
      </xs:extension>
    </xs:complexContent>
  </xs:complexType>
  <xs:element name="TestTask" substitutionGroup="msb:Task" type="msb:TestTaskType">
    <xs:annotation>
      <xs:documentation>Test task 1.</xs:documentation>
 </xs:annotation>
 </xs:element>
</xs:schema> 
```