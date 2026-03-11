<?xml version="1.0"?>
<!-- Summary report for GitHub Job Summaries (skip_check_run=true).
     Delegates to coverage-summary.xsl with a Job Summary-specific header. -->
<xsl:stylesheet version="2.0"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
    <xsl:import href="coverage-summary.xsl"/>
    <xsl:param name="tableHeader">Code Coverage Summary</xsl:param>
</xsl:stylesheet>
