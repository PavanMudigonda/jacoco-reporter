<?xml version="1.0"?>
<xsl:stylesheet version="2.0"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:xs="http://www.w3.org/2001/XMLSchema"
                xmlns:fn="http://www.w3.org/2005/xpath-functions"
                xmlns:ms="urn:schemas-microsoft-com:xslt"
                xmlns:dt="urn:schemas-microsoft-com:datatypes"
                >

    <xsl:output method="text"/>
    <xsl:strip-space elements="*"/>

    <xsl:param name="reportTitle">
        <xsl:value-of select="/report/@name" />
    </xsl:param>

<!--https://github.com/ikatyang/emoji-cheat-sheet/blob/master/README.md-->
<!--
    :radio_button:
    :x:
    
    :white_circle:
    :grey_question:
-->
    <xsl:template match="/">
# Coverage Report: <xsl:value-of select="$reportTitle" />

* <xsl:value-of select="/report/@name" />

<xsl:variable name="overallPercentage">
    <xsl:choose>
        <xsl:value-of select="format-number((100 * (/coverage/@branch-rate),'#.##')" /></xsl:otherwise>
    </xsl:choose>
</xsl:variable>

Outcome: <xsl:value-of select="$overallPercentage" />% Coverage
         | Lines Covered: <xsl:value-of select="/coverage/@lines-rate" />
         | Lines Missed: <xsl:value-of select="100 - (/coverage/@lines-rate)" />

## Details:

    <xsl:apply-templates select="/coverage/package" />
    </xsl:template>

    <xsl:template match="package">
### <xsl:value-of select="@name" />

        <xsl:apply-templates select="sources">
        </xsl:apply-templates>
    </xsl:template>

    <xsl:template match="sources">
        <xsl:variable name="linesMissed" select="counter[@type='LINE']/@missed" />
        <xsl:variable name="testOutcomeIcon">
            <xsl:choose>
                <xsl:when test="$linesMissed = '0'">:heavy_check_mark:</xsl:when>
                <xsl:otherwise>:x:</xsl:otherwise>
            </xsl:choose>
        </xsl:variable>

&lt;details&gt;
    &lt;summary&gt;
<xsl:value-of select="$testOutcomeIcon" />
<xsl:text> </xsl:text>
<xsl:value-of select="@name" />
    &lt;/summary&gt;

        <xsl:if test="$linesMissed != 0">
#### Lines Missed:
        </xsl:if>

        <xsl:if test="$linesMissed = 0">
#### All Lines Covered!
        </xsl:if>

        <xsl:apply-templates select="line[@mi='1']" />
&lt;/details&gt;

    </xsl:template>

    <xsl:template match="line[@mi='1']">
        <xsl:variable name="fileName" select="../@name" />
- Line #<xsl:apply-templates select="@nr" />|<xsl:value-of select="../../@name" />/<xsl:value-of select="$fileName" />
    </xsl:template>

</xsl:stylesheet>