<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:thl="java:org.thdl.tib.scanner.BasicTibetanTranscriptionConverter" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="2.0">
	<xsl:output method="text" encoding="UTF-8" indent="yes"/>

	<xsl:template match="/">
	    <xsl:apply-templates select="//*[starts-with(local-name(.), 'wr')]"/>
	</xsl:template>

	<xsl:template match="*">
	    <xsl:variable name="label">
            <xsl:choose>
                <xsl:when test="starts-with(label, 'Pa')">
                    <xsl:text>v.past</xsl:text>
                </xsl:when>
                <xsl:when test="starts-with(label, 'Pr')">
                    <xsl:text>v.pres</xsl:text>
                </xsl:when>
                <xsl:when test="starts-with(label, 'Fu')">
                    <xsl:text>v.fut</xsl:text>
                </xsl:when>
                <xsl:when test="starts-with(label, 'Im')">
                    <xsl:text>v.imp</xsl:text>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="label"/>
                </xsl:otherwise>
            </xsl:choose>
	    </xsl:variable>
	    <xsl:for-each select="orth">
	        <xsl:variable name="tib">
	            <xsl:choose>
	                <xsl:when test="ends-with(., 'rd') or ends-with(., 'ld')">
	                    <xsl:value-of select="thl:wylieToUnicode(normalize-space(substring(., 1, string-length(.)-1)))"/>
	                    <xsl:value-of select="thl:wylieToUnicode('d')"/>
	                </xsl:when>
	                <xsl:otherwise>
	                    <xsl:value-of select="thl:wylieToUnicode(normalize-space(.))"/>
	                </xsl:otherwise>
	            </xsl:choose>
            </xsl:variable>
            <xsl:value-of select="$tib"/>
            <xsl:text>|</xsl:text>
            <xsl:value-of select="$label"/>
            <xsl:text>&#xa;</xsl:text>
            <xsl:value-of select="$tib"/>
            <xsl:text>&#x0F0B;|</xsl:text>
            <xsl:value-of select="$label"/>
            <xsl:text>&#xa;</xsl:text>
            <xsl:if test="not($label='v.imp')">
                <xsl:value-of select="$tib"/>
                <xsl:text>&#x0F0B;པ&#x0F0B;|</xsl:text>
                <xsl:text>n.</xsl:text><xsl:value-of select="$label"/>
                <xsl:text>&#xa;</xsl:text>
                <xsl:value-of select="$tib"/>
                <xsl:text>&#x0F0B;པ|</xsl:text>
                <xsl:text>n.</xsl:text><xsl:value-of select="$label"/>
                <xsl:text>&#xa;</xsl:text>
                <xsl:value-of select="$tib"/>
                <xsl:text>&#x0F0B;བ&#x0F0B;|</xsl:text>
                <xsl:text>n.</xsl:text><xsl:value-of select="$label"/>
                <xsl:text>&#xa;</xsl:text>
                <xsl:value-of select="$tib"/>
                <xsl:text>&#x0F0B;བ|</xsl:text>
                <xsl:text>n.</xsl:text><xsl:value-of select="$label"/>
                <xsl:text>&#xa;</xsl:text>
            </xsl:if>
	    </xsl:for-each>
	</xsl:template>

</xsl:stylesheet>
