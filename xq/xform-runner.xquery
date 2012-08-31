xquery version "1.0";
declare namespace exist = "http://exist.sourceforge.net/NS/exist";
declare namespace request="http://exist-db.org/xquery/request";

(:
  
Punch list:
(must have)

(probably need)  
  * Add file manifest viewer (subform)

(might want)
  * Add trigger to see preview on save (may involve xq)
  * See if modals can be improved
  * Add keyboard command bindings
  
:)

declare option exist:serialize "method=xhtml media-type=text/xml";
declare option exist:serialize "indent=no";
declare option exist:serialize "process-xsl-pi=no";

let $attribute := request:set-attribute("betterform.filter.ignoreResponseBody", "true")

let $base_url := '/metadata/'
let $load_path := 'posted_data/'
let $param := request:get-parameter("fid", 0)

let $form_url := concat($base_url, $load_path, $param)

let $form :=
<html xmlns="http://www.w3.org/1999/xhtml" xmlns:xf="http://www.w3.org/2002/xforms"
  xmlns:ev="http://www.w3.org/2001/xml-events" xmlns:tei="http://www.tei-c.org/ns/1.0"
  xmlns:exist="http://exist.sourceforge.net/NS/exist">
  <head>
    <title>Shelley-Godwin Archive Metadata Editor</title>
    <link rel="stylesheet" type="text/css" href="../lib/bootstrap/css/bootstrap.min.css" />
    <link rel="stylesheet" type="text/css" href="../lib/FontAwesome/css/font-awesome.css" />
    <link rel="stylesheet" type="text/css" href="http://ajax.aspnetcdn.com/ajax/jquery.dataTables/1.8.2/css/jquery.dataTables.css" />
    <link rel="stylesheet" type="text/css" href="../lib/fancyBox/source/jquery.fancybox.css" />
    <!-- <link rel="stylesheet" type="text/css" href="../lib/dataTables/jquery.dataTables.css" /> -->
    <style type="text/css"><![CDATA[/**/
      body{
          line-height:19px;
      }
      #extent{
          margin-bottom:20px;
      }
      .popover-link{
          font-size:19px;
          padding-left:10px;
      }
      .xforms-alert{
          font-size:19px;
          padding-left:10px;
          color:rgb(185, 81, 74);
      }
      .page-controls{
          margin-top:2em;
      }
      .page-controls button {
            -webkit-border-radius: 15px;
            -moz-border-radius: 15px;
            border-radius: 15px;
      }
      .pager{
          text-align:left;
      }
      #institution-code {
            display: none;
      }
      #jsSave {
            width: 90%;
            margin-top: 20px;
      }
      /*]]></style>
    <xf:model id="teiHeader">
      <xf:instance id="itemMD" xmlns="http://www.tei-c.org/ns/1.0"
        src= "{$form_url}">
      </xf:instance>

      <xf:instance id="control-codes" xmlns="">
        <data>
          <boolean1>false</boolean1>
          <output-filename>temp.xml</output-filename>
          <institution-id></institution-id>
        </data>
      </xf:instance>

      <!-- Bindings -->
      <xf:bind id="title"
        nodeset="/tei:TEI/tei:teiHeader/tei:fileDesc/tei:titleStmt/tei:title[@type='main']"
        required="true()"></xf:bind>
      <xf:bind id="date"
        nodeset="/tei:TEI/tei:teiHeader/tei:profileDesc/tei:creation/tei:date/@when" type="gYear"></xf:bind>
      <xf:bind id="desc-label" nodeset="//tei:msDesc/tei:msContents/tei:summary" required="true()"></xf:bind>

      <xf:bind id="call-number" nodeset="//tei:msDesc/tei:msIdentifier/tei:idno" required="true()"></xf:bind>

      <xf:bind id="xtra-foliation" nodeset="instance('control-codes')/boolean1" type="boolean"></xf:bind>
      <xf:bind id="foliation-modern"
        nodeset="//tei:msDesc/tei:physDesc/tei:objectDesc/tei:supportDesc/tei:foliation[@xml:id='modern']"
        relevant="instance('control-codes')/boolean1 != 'false'"></xf:bind>

      <xf:bind id="meditor"
        nodeset="/tei:TEI/tei:teiHeader/tei:fileDesc/tei:titleStmt/tei:respStmt[@xml:id='md_editor']/tei:name"
        required="true()"></xf:bind>
      <xf:bind id="metadata-source"
        nodeset="//tei:msDesc/tei:additional/tei:adminInfo/tei:recordHist/tei:p/tei:bibl"
        required="true()"></xf:bind>

      <xf:bind id="change-author" nodeset="//tei:revisionDesc/tei:change/@who" readonly="true()"></xf:bind>
      <xf:bind id="change" nodeset="//tei:revisionDesc/tei:change" readonly="true()"></xf:bind>

      <!-- Submission -->
      <xf:submission id="save" method="put" replace="none">
        <xf:resource value="concat('/metadata/posted_data/', instance('control-codes')/output-filename)"></xf:resource>
      </xf:submission>

      <!-- Messages -->
      <!--<xf:message level="modal" ev:event="xforms-submit-error">Something went wrong with your submission. Please check that all required fields have been completed and no validation errors are present. If the problem persists email trevor.munoz@gmail.com</xf:message>-->
      <xf:message level="modal" ev:event="xforms-submit-done">Saved!</xf:message>

    </xf:model>
  </head>

  <body>
    <div class="container">
      <div class="jumbotron subhead">
        <h1><a href="/metadata/">Metadata Editor</a></h1>
        <p class="lead"><em>for the Shelley-Godwin Archive</em></p>
        <div class="navbar">
          <xf:trigger>
            <xf:label><i class="icon-book"></i> Basics</xf:label>
            <xf:toggle case="basics" ev:event="DOMActivate"></xf:toggle>
          </xf:trigger>
          <xf:trigger id="holdings">
            <xf:label><i class="icon-folder-open"></i> Holdings Info</xf:label>
            <xf:toggle case="holdings_info" ev:event="DOMActivate"></xf:toggle>
          </xf:trigger>
          <xf:trigger>
            <xf:label><i class="icon-leaf"></i> Physical Description</xf:label>
            <xf:toggle case="physical_description" ev:event="DOMActivate"></xf:toggle>
          </xf:trigger>
          <xf:trigger>
            <xf:label><i class="icon-pencil"></i> Hands</xf:label>
            <xf:toggle case="hand_info" ev:event="DOMActivate"></xf:toggle>
          </xf:trigger>
          <xf:trigger>
            <xf:label><i class="icon-sitemap"></i> Data Provenance</xf:label>
            <xf:toggle case="prov" ev:event="DOMActivate"></xf:toggle>
          </xf:trigger>
          <xf:trigger id="related-items">
            <xf:label><i class="icon-external-link"></i> Related Items</xf:label>
            <xf:toggle case="surrogates" ev:event="DOMActivate"></xf:toggle>
          </xf:trigger>
          <xf:trigger>
            <xf:label><i class="icon-cogs"></i> Changelog</xf:label>
            <xf:toggle case="admin_info" ev:event="DOMActivate"></xf:toggle>
          </xf:trigger>
        </div>
      </div>
      <div id="xform">
        <xf:switch>
          <xf:case id="basics">
          <div class="span6">
            <div class="progress progress-striped">
              <div class="bar" style="width: 14%;">
                <p>1 of 7</p>
              </div>
            </div>
            <div class="page-header">
            <h1>Basic Item Description</h1>
          </div>
          <xf:group>
            <p>
              <xf:input id="main-title" bind="title" incremental="true">
                <xf:label>Main title: </xf:label>
              </xf:input>
              <a class="popover-link" href="#" rel="popover" data-original-title="main title" data-content="A word, phrase, character, or group of characters that constitutes the 
                chief title of a resource (i.e. the title normally used when citing the resource) [source: MODS]">
                <i class="icon-info-sign icon-large"></i>
              </a>
            </p>
            <p>
              <xf:input id="creation-date" appearance="minimal" bind="date">
                <xf:label>Date created: </xf:label>
                <!--<xf:message ev:event="xforms-invalid">Dates must be of the form: YYYY</xf:message>-->
              </xf:input>
              <a class="popover-link" href="#" rel="popover" data-original-title="creation date" data-content="The date of creation of the resource, YYYY.">
                <i class="icon-info-sign icon-large"></i>
              </a>
            </p>
            <p>
              <xf:textarea id="item-label" bind="desc-label">
                <xf:label>Short description: </xf:label>
              </xf:textarea>
              <a class="popover-link" href="#" rel="popover" data-original-title="descriptive label" data-content="A short summary or overview of the 
                intellectual content of a manuscript or manuscript part. [source: TEI]">
                <i class="icon-info-sign icon-large"></i>
              </a>
            </p>
          </xf:group>
            <div class="page-controls span4">
              <ul class="pager">
              <li class="next">
                <xf:trigger id="next-to-holdings">
                  <xf:label>Next &#8594;</xf:label>
                  <xf:toggle case="holdings_info" ev:event="DOMActivate"></xf:toggle>
                </xf:trigger>
              </li>
            </ul>
            </div>
          </div>
        </xf:case>
          <xf:case id="holdings_info">
            <div class="span6">
              <div class="progress progress-striped">
                <div class="bar" style="width: 28%;">
                  <p>2 of 7</p>
                </div>
              </div>
          <div class="page-header">
            <h1>Holdings Information</h1>
          </div>
          <xf:group ref="//tei:msDesc/tei:msIdentifier">
            <p>
              <xf:select1 id="select-repo" ref="tei:repository" appearance="minimal">
                <xf:label>Host institution</xf:label>
                <xf:item>
                  <xf:label>British Library</xf:label>
                  <xf:value>bl</xf:value>
                </xf:item>
                <xf:item>
                  <xf:label>Harvard University, Houghton Library</xf:label>
                  <xf:value>mh</xf:value>
                </xf:item>
                <xf:item>
                  <xf:label>Huntington Library</xf:label>
                  <xf:value>hu</xf:value>
                </xf:item>
                <xf:item>
                  <xf:label>New York Public Library</xf:label>
                  <xf:value>pf</xf:value>
                </xf:item>
                <xf:item>
                  <xf:label>Oxford University, Bodleian Library</xf:label>
                  <xf:value>ox</xf:value>
                </xf:item>
                <xf:action ev:event="xforms-value-changed">
                  <xf:setvalue ref="instance('control-codes')/institution-id" value="instance('itemMD')//tei:repository"></xf:setvalue>
                </xf:action>
              </xf:select1>
            </p>
            <p>
              <xf:input id="lib-collection" ref="tei:collection" appearance="minimal">
                <xf:label>Name of collection: </xf:label>
              </xf:input>
              
              <xf:input id="lib-idno" bind="call-number" appearance="minimal">
                <xf:label>Call number/shelf mark for item: </xf:label>
                <xf:action ev:event="xforms-value-changed">
                  <xf:setvalue ref="instance('control-codes')/output-filename" value="concat(lower-case(translate(instance('itemMD')//tei:msDesc/tei:msIdentifier/tei:idno, ' .,', '_')), '.xml')"></xf:setvalue>
                </xf:action>
              </xf:input>
            </p>
          </xf:group>
            <div class="page-controls span4">
              <ul class="pager">
                <li class="prev">
                  <xf:trigger id="prev-to-basics">
                    <xf:label>&#8592; Previous</xf:label>
                    <xf:toggle case="basics" ev:event="DOMActivate"></xf:toggle>
                  </xf:trigger>
                </li>
                <li class="next">
                  <xf:trigger id="next-to-physDesc">
                    <xf:label>Next &#8594;</xf:label>
                    <xf:toggle case="physical_description" ev:event="DOMActivate"></xf:toggle>
                  </xf:trigger>
                </li>
              </ul>
            </div>
            </div>
        </xf:case>
          <xf:case id="physical_description">
            <div class="span6">
              <div class="progress progress-striped">
                <div class="bar" style="width: 43%;">
                  <p>3 of 7</p>
                </div>
              </div>
            </div>
          <div class="span12">
              <div class="page-header span6">
              <h1>Physical Description <small>Aspects of the form, support, and extent of a manuscript, as well as the styles of writing present</small></h1>
          </div>
          <xf:group ref="//tei:msDesc/tei:physDesc/tei:objectDesc/tei:supportDesc">
            <div id="extent" class="span12">
              <xf:input id="physical-extent" ref="tei:extent" appearance="minimal">
              <xf:label>Extent: </xf:label>
            </xf:input>
            <a class="popover-link" href="#" rel="popover" data-original-title="physical extent" data-content="Describes the approximate size of a 
              text as stored on some carrier medium, e.g., 163 leaves. [source: TEI]">
              <i class="icon-info-sign icon-large"></i>
            </a>
            </div>
            <div class="span4">
              <xf:textarea id="physical-support" ref="tei:support/tei:p" appearance="minimal">
                <xf:label>Describe the material support of the item: </xf:label>
              </xf:textarea>
            <a class="popover-link" href="#" rel="popover" data-original-title="support" data-content="Information about the physical carrier on 
              which a text is written. For paper, a discussion of any watermarks present may also be useful. [source: TEI]">
              <i class="icon-info-sign icon-large"></i>
            </a>
            </div>
              <div id="fol1" class="span4">
              <xf:textarea id="foliation-orig" ref="tei:foliation[@xml:id='original']/tei:p">
                <xf:label>Describe any (original) foliation scheme present: </xf:label>
              </xf:textarea>
            <a class="popover-link" href="#" rel="popover" data-original-title="foliation" data-content="Describe the scheme, medium or location of folio, 
              page, column, or line numbers written in the manuscript, frequently including a statement about when and, if known, by whom, 
              the numbering was done. [source: TEI]">
              <i class="icon-info-sign icon-large"></i>
            </a>
              </div>
            <div id="fol2" class="span4 offset4">
              <xf:input bind="xtra-foliation">
              <xf:label>Record another foliation scheme?</xf:label>
            </xf:input>
              <xf:textarea id="foliation-mod" bind="foliation-modern">
              <xf:label>Describe any additional foliation schemes present: </xf:label>
            </xf:textarea>
            </div>
            <div class="span12">
              <xf:textarea id="physical-condition" ref="tei:condition/tei:p">
                <xf:label>Describe the condition of the item: </xf:label>
              </xf:textarea>
            <a class="popover-link" href="#" rel="popover" data-original-title="physical condition" data-content="Summarize the overall physical state of 
              a manuscript. [source: TEI]">
              <i class="icon-info-sign icon-large"></i>
            </a>
            </div>
          </xf:group>
          </div>
              <div class="span6">
            <div class="page-controls span4">
              <ul class="pager">
                <li class="prev">
                  <xf:trigger id="prev-to-holdings">
                    <xf:label>&#8592; Previous</xf:label>
                    <xf:toggle case="holdings_info" ev:event="DOMActivate"></xf:toggle>
                  </xf:trigger>
                </li>
                <li class="next">
                  <xf:trigger id="next-to-hands">
                    <xf:label>Next &#8594;</xf:label>
                    <xf:toggle case="hand_info" ev:event="DOMActivate"></xf:toggle>
                  </xf:trigger>
                </li>
              </ul>
            </div>
            </div><!-- /.span6 -->
        </xf:case>
          <xf:case id="hand_info">
            <div class="span6">
              <div class="progress progress-striped">
                <div class="bar" style="width: 57%;">
                  <p>4 of 7</p>
                </div>
              </div>
          <div class="page-header">
            <h1>Manuscript Hands</h1>
          </div>
          <xf:group>
            <p>
              <xf:textarea id="manu-hands" ref="//tei:msDesc/tei:physDesc/tei:handDesc/tei:p">
                <xf:label>Describe hands found in the item: </xf:label>
              </xf:textarea>
              <a class="popover-link" href="#" rel="popover" data-original-title="manuscript hands" data-content="A short description of all the distinct hands
                distinguished within a manuscript. [source: TEI]">
                <i class="icon-info-sign icon-large"></i>
              </a>
            </p>
          </xf:group>
            <div class="page-controls span4">
              <ul class="pager">
                <li class="prev">
                  <xf:trigger id="prev-to-physDesc">
                    <xf:label>&#8592; Previous</xf:label>
                    <xf:toggle case="physical_description" ev:event="DOMActivate"></xf:toggle>
                  </xf:trigger>
                </li>
                <li class="next">
                  <xf:trigger id="next-to-prov">
                    <xf:label>Next &#8594;</xf:label>
                    <xf:toggle case="prov" ev:event="DOMActivate"></xf:toggle>
                  </xf:trigger>
                </li>
              </ul>
            </div>
            </div><!-- /.span6 -->
        </xf:case>
          <xf:case id="prov">
            <div class="span6">
              <div class="progress progress-striped">
                <div class="bar" style="width: 71%;">
                  <p>5 of 7</p>
                </div>
              </div>
          <div class="page-header">
            <h1>Data Provenance</h1>
          </div>
          <xf:group ref="//tei:msDesc/tei:additional/tei:adminInfo/tei:recordHist">
            <p>
              <xf:input id="metadata-creator" bind="meditor">
                <xf:label>Metadata created/edited for SGA by: </xf:label>
              </xf:input>
              <a class="popover-link" href="#" rel="popover" data-original-title="metadata editor" data-content="Name of the person principally responsible
                for creating metadata about this item.">
                <i class="icon-info-sign icon-large"></i>
              </a>
            </p>
            <p>
              <xf:textarea id="source" bind="metadata-source">
                <xf:label>Source used: </xf:label>
              </xf:textarea>
              <a class="popover-link" href="#" rel="popover" data-original-title="metadata source" data-content="A bibliographic description/citation of the source 
                from which cataloguing information was taken. [source: TEI]">
                <i class="icon-info-sign icon-large"></i>
              </a>
            </p>
          </xf:group>
            <div class="page-controls span4">
              <ul class="pager">
                <li class="prev">
                  <xf:trigger id="prev-to-hands">
                    <xf:label>&#8592; Previous</xf:label>
                    <xf:toggle case="hand_info" ev:event="DOMActivate"></xf:toggle>
                  </xf:trigger>
                </li>
                <li class="next">
                  <xf:trigger id="next-to-surrogates">
                    <xf:label>Next &#8594;</xf:label>
                    <xf:toggle case="surrogates" ev:event="DOMActivate"></xf:toggle>
                  </xf:trigger>
                </li>
              </ul>
            </div>
            </div><!-- /.span6 -->
        </xf:case>
          <xf:case id="surrogates">
            <div class="span6">
              <div class="progress progress-striped">
                <div class="bar" style="width: 86%;">
                  <p>6 of 7</p>
                </div>
              </div>
          <div class="page-header">
            <h1>Related Items <small>Most of the items in the Shelley-Godwin Archive have been published in facsimile editions. 
              This section records information about those surrogate items.</small></h1>
          </div>
          <xf:group ref="//tei:msDesc/tei:additional/tei:listBibl">
            <p>
              <xf:textarea id="surrogate1" ref="tei:bibl">
                <xf:label>Citation for related/additional surrogate for this item: </xf:label>
              </xf:textarea>
              <a class="popover-link" href="#" rel="popover" data-original-title="related item" data-content="A bibliographic description/citation
                of any additional representation of the manuscript being described. [source: TEI]">
                <i class="icon-info-sign icon-large"></i>
              </a>
            </p>
          </xf:group>
            <div class="page-controls span4">
              <p>
                <xf:trigger id="next-to-manifest">
                  <xf:label><i class="icon-picture"></i> Link page images to this Item</xf:label>
                <xf:toggle case="file_manifest" ev:event="DOMActivate"></xf:toggle>
              </xf:trigger>
              </p>
              <ul class="pager">
                <li class="prev">
                  <xf:trigger id="prev-to-prov">
                    <xf:label>&#8592; Previous</xf:label>
                    <xf:toggle case="prov" ev:event="DOMActivate"></xf:toggle>
                  </xf:trigger>
                </li>
                <li class="next">
                  <xf:trigger id="surrogate-to-finish">
                    <xf:label>Finish</xf:label>
                    <xf:toggle case="admin_info" ev:event="DOMActivate"></xf:toggle>
                  </xf:trigger>
                </li>
              </ul>
            </div>
            </div><!-- /.span6 -->
        </xf:case>
          <xf:case id="file_manifest">
            <div class="page-header span8">
              <h1>Link Page Images <small>Label image files with descriptive information indicating their relationship to the original item</small></h1>
            </div>
            <div class="span12">
                <div id="ajax-loader">
                    <img src="../img/ajax-loader.gif" title="loader graphic" />
                </div>
                <div id="itemSelector" class="span8">
                    <p><xf:output id="institution-code" ref="instance('control-codes')/institution-id"></xf:output></p>
                    <p><strong>Select an item:</strong></p>
                    <ul id="ajax-file-manifest" class="nav nav-pills nav-stacked">
                    </ul>
                </div>
                <div class="modal hide" id="loading_modal">
                    <div class="modal-header">
                        <h3>Loading</h3>
                    </div>
                    <div class="modal-body">
                        <p>Retrieving page images for this item. Please wait.</p>
                    </div>
                </div>
                <div id="imageTable" class="span8">
                    <h2 id="itemID"></h2>
                    <table id="imageDataTable" class="table table-striped table-bordered">
                        <thead>
                            <tr>
                                <th>filename</th>
                                <th>link</th>
                                <th>label</th>
                            </tr>
                        </thead>
                        <tbody id="page-images">
                        </tbody>
                    </table>
                    <div id="tableSaveButton" class="span8">
                        <button id="jsSave" class="btn btn-primary">Save</button>
                    </div>
                    <div id="msgPlaceHolder" class="span8">&#xa0;</div>
                </div>
            </div><!-- /.span12 -->
            <div class="page-controls span4">
              <ul class="pager">
                <li class="prev">
                  <xf:trigger id="prev-to-manifest">
                    <xf:label>&#8592; Back</xf:label>
                    <xf:toggle case="file_manifest" ev:event="DOMActivate"></xf:toggle>
                  </xf:trigger>
                </li>
                <li class="next">
                  <xf:trigger id="img-to-finish">
                    <xf:label>Finish</xf:label>
                    <xf:toggle case="admin_info" ev:event="DOMActivate"></xf:toggle>
                  </xf:trigger>
                </li>
              </ul>
            </div>
          </xf:case>
          <xf:case id="admin_info">
            <div class="span6">
              <div class="progress progress-striped">
                <div class="bar" style="width: 100%;">
                  <p>7 of 7</p>
                </div>
              </div>
          <div class="page-header">
            <h1>Edit Changelog <small>Help the Shelley-Godwin Archive keep track of everyone's contributions</small></h1>
          </div>
          <table xmlns="http://www.w3.org/1999/xhtml" class="table table-bordered table-striped">
          <thead xmlns="http://www.w3.org/1999/xhtml">
            <tr xmlns="http://www.w3.org/1999/xhtml">
                <th xmlns="http://www.w3.org/1999/xhtml">Timestamp</th>
                <th xmlns="http://www.w3.org/1999/xhtml">Author</th>
                <th xmlns="http://www.w3.org/1999/xhtml">Change(s)</th>
            </tr>
          </thead>
          <tbody>
          <xf:repeat id="change-repeat" nodeset="instance('itemMD')//tei:revisionDesc/tei:change">
            <tr>
                    <td><xf:output ref="./@when"></xf:output></td>
                    <td>
                    <xf:input ref="./@who">
                        <xf:action ev:event="DOMFocusIn">
                            <xf:load resource="javascript:makeEditable()"></xf:load>
                        </xf:action>
                    </xf:input>
                    </td>
                    <td><xf:input ref="."></xf:input></td>
            </tr>
            </xf:repeat>
          </tbody>
          </table>
          <xf:trigger>
                <xf:label>Add an entry</xf:label>
                    <xf:action ev:event="DOMActivate">
                    <xf:insert nodeset="//tei:revisionDesc/tei:change" at="last()" position="after"/>
                    <xf:setvalue ref="instance('control-codes')/output-filename" value="concat(lower-case(translate(instance('itemMD')//tei:msDesc/tei:msIdentifier/tei:idno, ' .,', '_')), '.xml')"></xf:setvalue>
                    <xf:setvalue ref="//tei:revisionDesc/tei:change[last()]/@when" value="now()"></xf:setvalue>
                    <xf:setvalue ref="//tei:revisionDesc/tei:change[last()]/@who" value="'Click to edit'"></xf:setvalue>
                    <xf:setvalue ref="//tei:revisionDesc/tei:change[last()]" value="'Click to edit'"></xf:setvalue>
                    </xf:action>
          </xf:trigger>
            </div><!-- /.span6 -->
            <div class="page-controls span6">
              <ul class="pager">
                <li class="previous">
                  <xf:trigger id="prev-from-submit">
                    <xf:label>&#8592; Go back</xf:label>
                    <xf:toggle case="surrogates" ev:event="DOMActivate"></xf:toggle>
                  </xf:trigger>
                </li>
                <li class="next">
                  <xf:submit id="finish" submission="save">
                    <xf:label>Save</xf:label>
                  </xf:submit>
                </li>
              </ul>
            </div>
        </xf:case>
        </xf:switch>
      </div><!-- /#xform -->
      <div class="footer span12">
      
        <p>
            <small>Powered by <a href="http://twitter.github.com/bootstrap/index.html">Bootstrap</a>, <a href="http://fortawesome.github.com/Font-Awesome">Font Awesome</a>, and poetry.</small>
        </p>
      </div>
    </div><!-- /.container -->
    <!-- Just scripts below here -->
    <script type="text/javascript" src="https://ajax.googleapis.com/ajax/libs/jquery/1.7.2/jquery.min.js"></script>
    <!-- <script type="text/javascript" src="../lib/jquery-1.7.2.min.js"></script> -->
    <script type="text/javascript" src="../lib/bootstrap/js/bootstrap.min.js"></script>
    <script type="text/javascript" src="../lib/bootstrap/js/bootstrap-alert.js"></script>
    <script type="text/javascript" charset="utf8" src="http://ajax.aspnetcdn.com/ajax/jquery.dataTables/1.8.2/jquery.dataTables.min.js"></script>
    <!-- <script type="text/javascript" src="../lib/dataTables/jquery.dataTables.min.js"></script> -->
    <script type="text/javascript" src="../lib/jquery.jeditable.mini.js"></script>
    <script type="text/javascript" src="../lib/fancyBox/source/jquery.fancybox.pack.js"></script>
    <script type="text/javascript" src="../js/sga.js"></script>
    <script type="text/javascript">
    <![CDATA[
        var makeEditable = function() {
        $('tr.xforms-repeat-item').last().find('input').removeAttr('readonly');
        }]]>
    </script>
    </body>
</html>

let $xslt-pi := processing-instruction xml-stylesheet {'type="text/xsl" href="http://50.19.209.106/fs/xforms/xsltforms/xsltforms.xsl" '}
let $css-pi := processing-instruction css-conversion {'no'}

return ($xslt-pi,$css-pi,$form)
