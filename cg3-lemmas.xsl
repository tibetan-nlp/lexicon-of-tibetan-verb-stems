<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:thl="java:org.thdl.tib.scanner.BasicTibetanTranscriptionConverter"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="2.0">
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
            <xsl:variable name="volition">
                <xsl:for-each select="volition/label">
                    <xsl:value-of select="substring-before(normalize-space(.), ':')"/>
                </xsl:for-each>
            </xsl:variable>
            <xsl:variable name="arguments">
                <xsl:value-of
                        select="lower-case(replace(substring-before(substring-after(syntax/text()[2], '['), '.]'), '\.\s+', '-'))"/>
            </xsl:variable>
            <xsl:variable name="gloss">
                <xsl:value-of select="replace(substring-after(replace(normalize-space(lower-case(replace(trans, '[A-Z]{2,}', ''))), '\s*meaning:\s*', ''), 'to '), '([a-z\s]+).*', '$1')"/>
            </xsl:variable>
            <xsl:variable name="tags">
                <xsl:if test="volition">
                    <xsl:choose>
                        <xsl:when test="$volition='Voluntary'">
                            <xsl:text>@vol </xsl:text>
                        </xsl:when>
                        <xsl:when test="$volition='Involuntary'">
                            <xsl:text>@inv </xsl:text>
                        </xsl:when>
                        <xsl:when test="$volition='VoluntaryInvoluntary'">
                            <xsl:text>@mix </xsl:text>
                        </xsl:when>
                        <xsl:when test="$volition='InvoluntaryVoluntary'">
                            <xsl:text>@mix </xsl:text>
                        </xsl:when>
                        <xsl:when test="normalize-space($volition) != ''">
                            <xsl:text>@err:</xsl:text>
                            <xsl:value-of select="$volition"/>
                        </xsl:when>
                    </xsl:choose>
                </xsl:if>
                <xsl:if test="syntax">
                    <xsl:if test="normalize-space($arguments) != ''">
                        <xsl:for-each select="tokenize($arguments, '-')">
                            <xsl:text>@</xsl:text>
                            <xsl:value-of select="."/>
                            <xsl:text> </xsl:text>
                        </xsl:for-each>
                        <xsl:text>@</xsl:text>
                        <xsl:value-of select="$arguments"/>
                        <xsl:text> </xsl:text>
                    </xsl:if>
                </xsl:if>
                <xsl:if test="normalize-space($gloss)">
                  <xsl:text>~</xsl:text>
                  <xsl:value-of select="replace(normalize-space($gloss), '([a-z]+)\s.*', '$1…')"/>
                  <xsl:text> </xsl:text>
                </xsl:if>
            </xsl:variable>
            <xsl:if test="normalize-space($tags)">
                <xsl:text>ADD (</xsl:text>
                <xsl:value-of select="normalize-space($tags)"/>
                <xsl:text>) (&quot;</xsl:text>
                <xsl:value-of select="concat($lemma, $suffix)"/>
                <xsl:text>&quot; VERB);</xsl:text>
                <xsl:text>&#xa;</xsl:text>
            </xsl:if>
        </xsl:if>
        <!-- <xsl:if test="./auxillary">
            <xsl:value-of select="concat($lemma, '&#x221A;x')"/>
            <xsl:text>&#xa;</xsl:text>
        </xsl:if> -->
    </xsl:template>

    <xsl:template name="toUnicode">
        <xsl:param name="wylie" select="''"/>
        <xsl:choose>
            <xsl:when test="ends-with($wylie, 'rd') or ends-with($wylie, 'ld')">
                <xsl:value-of
                        select="thl:wylieToUnicode(normalize-space(substring($wylie, 1, string-length($wylie)-1)))"/>
                <xsl:value-of select="thl:wylieToUnicode('d')"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="thl:wylieToUnicode(normalize-space($wylie))"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

</xsl:stylesheet>
