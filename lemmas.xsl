<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:thl="java:org.thdl.tib.scanner.BasicTibetanTranscriptionConverter" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="2.0">
    <xsl:output method="text" encoding="UTF-8" indent="yes"/>

    <xsl:template match="/">
        <xsl:apply-templates select="//entry[wrI]"/> <!-- ignore auxiliaries -->
    </xsl:template>

    <xsl:template match="entry">
        <xsl:variable name="wylie" select="headword/orth[1]"/> <!-- get first headword value -->
        <xsl:variable name="lemma">
            <xsl:call-template name="toUnicode">
                <xsl:with-param name="wylie">
                    <xsl:value-of select="$wylie"/>
                </xsl:with-param>
            </xsl:call-template>
            <xsl:text>&#x0F0B;</xsl:text> <!-- add tsheg -->
        </xsl:variable>
        <xsl:variable name="stems" select="*[starts-with(local-name(.), 'wr')]"/>
        <xsl:if test="count($stems) > 0">
            <xsl:variable name="suffix">
                <xsl:variable name="sameBefore"
                              select="count(./preceding-sibling::entry[wrI][headword/orth[1]=$wylie])"/>
                <xsl:choose>
                    <xsl:when test="$sameBefore > 0">
                        <xsl:text>&#x221A;</xsl:text>
                        <xsl:value-of select="$sameBefore+1"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:variable name="sameAfter"
                                      select="count(./following-sibling::entry[wrI][headword/orth[1]=$wylie])"/>
                        <xsl:if test="$sameAfter > 0">
                            <xsl:text>&#x221A;1</xsl:text>
                        </xsl:if>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:variable>
            <xsl:value-of select="concat($lemma, $suffix)"/>
            <xsl:text>&#xa;</xsl:text>
        </xsl:if>
        <xsl:if test="./auxillary">
            <xsl:value-of select="concat($lemma, '&#x221A;x')"/>
            <xsl:text>&#xa;</xsl:text>
        </xsl:if>
    </xsl:template>

    <xsl:template name="toUnicode">
        <xsl:param name="wylie" select="''"/>
        <xsl:choose>
            <xsl:when test="ends-with($wylie, 'rd') or ends-with($wylie, 'ld')">
                <xsl:value-of select="thl:wylieToUnicode(normalize-space(substring($wylie, 1, string-length($wylie)-1)))"/>
                <xsl:value-of select="thl:wylieToUnicode('d')"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="thl:wylieToUnicode(normalize-space($wylie))"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

</xsl:stylesheet>