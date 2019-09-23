<?xml version="1.0" encoding="UTF-8"?>

<!--

    AmericasViaOAAP.xsl
    This simply imports Americas.xsl and hides anything that the CSS isn't capable of hiding.

-->

<xsl:stylesheet
    xmlns:dri="http://di.tamu.edu/DRI/1.0/"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">

  <xsl:import href="../Americas/Americas.xsl"/>

  <!-- Prevent the section titled "This item appears in the following Collection(s)" from appearing.  -->
  <xsl:template match="dri:referenceSet[@type = 'detailList'][@rend='hierarchy']" priority="2"/>
    
</xsl:stylesheet>
