<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:thl="java:org.thdl.tib.scanner.BasicTibetanTranscriptionConverter"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="2.0">
    <xsl:output method="text" encoding="UTF-8" indent="yes"/>

    <xsl:template match="/">
        <xsl:apply-templates select="//entry"/>
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
            <xsl:for-each select="$stems">
                <xsl:call-template name="verbform">
                    <xsl:with-param name="item" select="."/>
                    <xsl:with-param name="label">
                        <xsl:choose>
                            <xsl:when test="starts-with(./label, 'Pa')">
                                <xsl:text>v.past</xsl:text>
                            </xsl:when>
                            <xsl:when test="starts-with(./label, 'Pr')">
                                <xsl:text>v.pres</xsl:text>
                            </xsl:when>
                            <xsl:when test="starts-with(./label, 'Fu')">
                                <xsl:text>v.fut</xsl:text>
                            </xsl:when>
                            <xsl:when test="starts-with(./label, 'Im')">
                                <xsl:text>v.imp</xsl:text>
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:value-of select="./label"/>
                            </xsl:otherwise>
                        </xsl:choose>
                    </xsl:with-param>
                    <xsl:with-param name="lemma" select="concat($lemma, $suffix)"/>
                </xsl:call-template>
            </xsl:for-each>
        </xsl:if>
        <xsl:if test="./auxillary">
            <xsl:call-template name="verbform">
                <xsl:with-param name="item" select="./auxillary"/>
                <xsl:with-param name="default" select="$wylie"/>
                <xsl:with-param name="label" select="'v.invar'"/>
                <xsl:with-param name="lemma" select="concat($lemma, '&#x221A;x')"/>
            </xsl:call-template>
        </xsl:if>
    </xsl:template>

    <xsl:template name="verbform">
        <xsl:param name="item"/>
        <xsl:param name="default" select="''"/>
        <xsl:param name="label" select="''"/>
        <xsl:param name="lemma" select="''"/>

        <xsl:variable name="orth">
            <xsl:choose>
                <xsl:when test="$item/orth">
                    <xsl:copy-of select="$item/orth"/>
                </xsl:when>
                <xsl:when test="$default != ''">
                    <orth><xsl:value-of select="$default"/></orth>
                </xsl:when>
            </xsl:choose>
        </xsl:variable>
        <xsl:for-each select="$orth/orth">
            <xsl:variable name="form">
                <xsl:call-template name="toUnicode">
                    <xsl:with-param name="wylie" select="."/>
                </xsl:call-template>
            </xsl:variable>
            <xsl:call-template name="tshegVariants">
                <xsl:with-param name="form" select="$form"/>
                <xsl:with-param name="label" select="$label"/>
                <xsl:with-param name="lemma" select="$lemma"/>
            </xsl:call-template>
            <xsl:if test="not($label='v.imp')">
                <xsl:call-template name="tshegVariants">
                    <xsl:with-param name="form" select="concat($form, '&#x0F0B;པ')"/>
                    <xsl:with-param name="label" select="concat('n.', $label)"/>
                    <xsl:with-param name="lemma" select="$lemma"/>
                </xsl:call-template>
                <xsl:call-template name="tshegVariants">
                    <xsl:with-param name="form" select="concat($form, '&#x0F0B;བ')"/>
                    <xsl:with-param name="label" select="concat('n.', $label)"/>
                    <xsl:with-param name="lemma" select="$lemma"/>
                </xsl:call-template>
            </xsl:if>
        </xsl:for-each>
    </xsl:template>

    <xsl:template name="tshegVariants">
        <xsl:param name="form"/>
        <xsl:param name="label"/>
        <xsl:param name="lemma"/>

        <!-- without tsheg -->
        <xsl:value-of select="$form"/>
        <xsl:text>&#x9;</xsl:text>
        <xsl:value-of select="$label"/>
        <xsl:text>&#x9;</xsl:text>
        <xsl:value-of select="$lemma"/>
        <xsl:text>&#xa;</xsl:text>

        <!-- with tsheg -->
        <xsl:value-of select="$form"/>
        <xsl:text>&#x0F0B;</xsl:text>
        <xsl:text>&#x9;</xsl:text>
        <xsl:value-of select="$label"/>
        <xsl:text>&#x9;</xsl:text>
        <xsl:value-of select="$lemma"/>
        <xsl:text>&#xa;</xsl:text>
    </xsl:template>

    <xsl:template name="toUnicode">
        <xsl:param name="wylie" select="''"/>
        <xsl:choose>
            <xsl:when test='$wylie = "&apos;krongs"'>
                <xsl:text>འཀྲོངས</xsl:text>
            </xsl:when>
            <xsl:when test="$wylie = 'bjid'">
                <xsl:text>བཇིད</xsl:text>
            </xsl:when>
            <xsl:when test="$wylie = 'bnyags'">
                <xsl:text>བཉགས</xsl:text>
            </xsl:when>
            <xsl:when test="$wylie = 'bnab'">
                <xsl:text>བནབ</xsl:text>
            </xsl:when>
            <xsl:when test="$wylie = 'dphrog'">
                <xsl:text>དཕྲོག</xsl:text>
            </xsl:when>
            <xsl:when test="$wylie = 'gstsan'">
                <xsl:text>གསྩན</xsl:text>
            </xsl:when>
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