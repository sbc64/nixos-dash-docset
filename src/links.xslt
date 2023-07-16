<?xml version="1.0"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xlink="https://www.w3.org/1999/xlink" version="1.0">
  <xsl:output method="html" />
  <xsl:template match="/">
    <xsl:copy>
      <xsl:copy-of select="@*" />
      <xsl:apply-templates select="*" />
    </xsl:copy>
  </xsl:template>
  <xsl:template match="link">
    <xsl:variable name="url" select="@xlink:href" />
    <a href="{$url}"><xsl:value-of select="."/></a>
  </xsl:template>
</xsl:stylesheet>
