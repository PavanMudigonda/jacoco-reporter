<?xml version="1.0"?>
<xsl:stylesheet version="2.0"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:xs="http://www.w3.org/2001/XMLSchema"
                xmlns:fn="http://www.w3.org/2005/xpath-functions"
                xmlns:ms="urn:schemas-microsoft-com:xslt"
                xmlns:dt="urn:schemas-microsoft-com:datatypes"
                xmlns:nuxml="urn:nuxml"
                xmlns:trx="http://microsoft.com/schemas/VisualStudio/TeamTest/2010"
                >

    <xsl:output method="text" encoding="UTF-8"/>
    <xsl:strip-space elements="*"/>

    <xsl:param name="reportTitle">
        <xsl:value-of select="/test-results/@name" />
        <xsl:text>_</xsl:text>
        <xsl:value-of select="/test-results/@date" />
        <xsl:text>_</xsl:text>
        <xsl:value-of select="/test-results/@time" />
    </xsl:param>

<!--https://github.com/ikatyang/emoji-cheat-sheet/blob/master/README.md-->
<!--
    :radio_button:
    :x:
    
    :white_circle:
    :grey_question:
-->
    <xsl:template match="/">
# Test Report: <xsl:value-of select="$reportTitle" />

* Date: <xsl:value-of select="/test-results/@date" />
* Time: <xsl:value-of select="/test-results/@time" />

Expand the following summaries for more details:

&lt;details&gt;
    &lt;summary&gt; Environment:
    &lt;/summary&gt;

| **Env** | |
|--|--|
| **`user`:**          | `<xsl:value-of select="/test-results/environment/@user" />`
| **`cwd`:**           | `<xsl:value-of select="/test-results/environment/@cwd" />`
| **`os-version`:**    | `<xsl:value-of select="/test-results/environment/@os-version" />`
| **`user-domain`:**   | `<xsl:value-of select="/test-results/environment/@user-domain" />`
| **`machine-name`:**  | `<xsl:value-of select="/test-results/environment/@machine-name" />`
| **`nunit-version`:** | `<xsl:value-of select="/test-results/environment/@nunit-version" />`
| **`clr-version`:**   | `<xsl:value-of select="/test-results/environment/@clr-version" />`
| **`platform`:**      | `<xsl:value-of select="/test-results/environment/@platform" />`



&lt;/details&gt;

<xsl:variable name="passedCount" select="/test-results/@total - /test-results/@errors - /test-results/@failures - /test-results/@not-run - /test-results/@inconclusive - /test-results/@ignored - /test-results/@skipped - /test-results/@invalid" />

&lt;details&gt;
    &lt;summary&gt; Outcome: <xsl:value-of select="/test-rsults/test-suite/@result"
        /> | Total Tests: <xsl:value-of select="/test-results/@total"
        /> | Passed: <xsl:value-of select="$passedCount"
        /> | Failed: <xsl:value-of select="/test-results/@failures" />
    &lt;/summary&gt;

| **Counters** | |
|-|-|
| **Total:**        | <xsl:value-of select="/test-results/@total" />
| **Errors:**       | <xsl:value-of select="/test-results/@errors" />
| **Failures:**     | <xsl:value-of select="/test-results/@failures" />
| **Not-run:**      | <xsl:value-of select="/test-results/@not-run" />
| **Inconclusive:** | <xsl:value-of select="/test-results/@inconclusive" />
| **Ignored:**      | <xsl:value-of select="/test-results/@ignored" />
| **Skipped:**      | <xsl:value-of select="/test-results/@skipped" />
| **Invalid:**      | <xsl:value-of select="/test-results/@invalid" />



&lt;/details&gt;


## Tests:

        <xsl:apply-templates select="/test-results/test-suite" />
    </xsl:template>

    <xsl:template match="test-suite">
        <xsl:param name="parentName" />
        <xsl:variable name="myName">
            <xsl:value-of select="$parentName" />
            <xsl:text> / </xsl:text>
            <xsl:value-of select="@name" />
        </xsl:variable>

        <xsl:if test="count(results/test-case)">
### <xsl:value-of select="$myName" />
            <xsl:apply-templates select="results/test-case">
                <xsl:with-param name="parentName" select="$myName" />
            </xsl:apply-templates>
        </xsl:if>

        <xsl:apply-templates select="results/test-suite">
            <xsl:with-param name="parentName" select="$myName" />
        </xsl:apply-templates>

    </xsl:template>

    <xsl:template match="test-case">
        <xsl:param name="parentName" />
        <xsl:variable name="myName">
            <xsl:value-of select="$parentName" />
            <xsl:text> / </xsl:text>
            <xsl:value-of select="@name" />
        </xsl:variable>
        <xsl:variable name="testResult"
                      select="@result" />
        <xsl:variable name="testOutcomeIcon">
            <xsl:choose>
                <xsl:when test="$testResult = 'Success'">:heavy_check_mark:</xsl:when>
                <xsl:when test="$testResult = 'Failure'">:x:</xsl:when>
                <!-- <xsl:when test="$testResult = 'NotExecuted'">:radio_button:</xsl:when> -->
                <xsl:otherwise>:grey_question:</xsl:otherwise>
            </xsl:choose>
        </xsl:variable>

&lt;details&gt;
    &lt;summary&gt;
<xsl:value-of select="$testOutcomeIcon" />
<xsl:text> </xsl:text>
<xsl:value-of select="@name" />
    &lt;/summary&gt;

<xsl:value-of select="@description" />

| | |
|-|-|
| **Parent:**        | `<xsl:value-of select="$parentName" />`
| **Name:**          | `<xsl:value-of select="@name" />`
| **Outcome:**       | `<xsl:value-of select="$testResult" />` <xsl:value-of select="$testOutcomeIcon" />
| **Time:**          | `<xsl:value-of select="@time" />` seconds

        <xsl:apply-templates select="failure" />
&lt;/details&gt;
    
    </xsl:template>

    <xsl:template match="failure">

&lt;details&gt;
    &lt;summary&gt;Error Message:&lt;/summary&gt;

```text
<xsl:value-of select="message" />
```
&lt;/details&gt;

&lt;details&gt;
    &lt;summary&gt;Error Stack Trace:&lt;/summary&gt;

```text
<xsl:value-of select="stack-trace" />
```
&lt;/details&gt;

    </xsl:template>

</xsl:stylesheet>
