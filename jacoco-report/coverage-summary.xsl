<?xml version="1.0"?>
<xsl:stylesheet version="2.0"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

    <xsl:output method="text"/>
    <xsl:strip-space elements="*"/>

    <xsl:param name="reportTitle">
        <xsl:value-of select="/report/@name"/>
    </xsl:param>

    <!-- "Coverage Report" for check-run summaries, "Code Coverage Summary" for job summaries -->
    <xsl:param name="tableHeader">Coverage Report</xsl:param>

    <xsl:template match="/">
# Coverage Report: <xsl:value-of select="$reportTitle"/>

* <xsl:value-of select="/report/@name"/>

<xsl:variable name="covered" select="/report/counter[@type='LINE']/@covered"/>
<xsl:variable name="missed"  select="/report/counter[@type='LINE']/@missed"/>

<xsl:variable name="overallPercentage">
    <xsl:choose>
        <xsl:when test="$missed = 0">100</xsl:when>
        <xsl:when test="$covered = 0">0</xsl:when>
        <xsl:otherwise>
            <xsl:value-of select="format-number(($covered div ($covered + $missed)) * 100, '#.##')"/>
        </xsl:otherwise>
    </xsl:choose>
</xsl:variable>

| <xsl:value-of select="$tableHeader"/>        | Value |
|----------------------------------------------|-------|
| Code Coverage %                              | <xsl:value-of select="$overallPercentage"/>% |
| :heavy_check_mark: Number of Lines Covered   | <xsl:value-of select="$covered"/> |
| :x: Number of Lines Missed                   | <xsl:value-of select="$missed"/> |
| Total Number of Lines                        | <xsl:value-of select="$covered + $missed"/> |

    </xsl:template>

</xsl:stylesheet>
