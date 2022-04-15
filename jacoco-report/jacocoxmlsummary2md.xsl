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
        <xsl:when test="/report/counter[@type='LINE']/@missed = 0">100 and "/report/counter[@type='LINE']/@covered"!= 0</xsl:when>
        <xsl:otherwise><xsl:value-of select="format-number(((/report/counter[@type='LINE']/@covered) div ( (/report/counter[@type='LINE']/@covered)+(/report/counter[@type='LINE']/@missed) ) * 100),'#.##')" /></xsl:otherwise>
    </xsl:choose>
</xsl:variable>

<xsl:variable name="overallPercentage">
    <xsl:choose>
        <xsl:when test="/report/counter[@type='LINE']/@missed = 0">100 and "/report/counter[@type='LINE']/@covered"= 0</xsl:when>
        <xsl:otherwise><xsl:value-of select="format-number(0,'#.##')" /></xsl:otherwise>
    </xsl:choose>
</xsl:variable>
      
      
| Outcome                 | Value                                                               |
|-------------------------|---------------------------------------------------------------------|
| Code Coverage %         | <xsl:value-of select="$overallPercentage" />% Coverage              |
| Number of Lines Covered | <xsl:value-of select="/report/counter[@type='LINE']/@covered" />    |
| Number of Lines Missed  | <xsl:value-of select="/report/counter[@type='LINE']/@missed" />     |
| Total Number of Lines   | <xsl:value-of select="/report/counter[@type='LINE']/@missed + /report/counter[@type='LINE']/@covered" />     |

</xsl:template>

</xsl:stylesheet>
