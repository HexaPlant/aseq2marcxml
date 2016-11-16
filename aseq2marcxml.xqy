xquery version "3.0";

(:
:   Module Name: ASEQ/XML ti MARC/XML using Zorba
:
:   Module Version: 0.1
:
:   Date: 2016 November 16
:
:   Copyright: Apache License Version 2
:
:   Proprietary XQuery Extensions Used: Zorba (expath)
:
:   Xquery Specification: January 2007
:
:   Module Overview:  ASEQ/XML Bibliographic records to MARX / XML
:
:   Run: zorba -i f -q aseq2marcxml.xql -e aseqxml:="../location/of/aseq.xml"
:)

(:~
:   Transforms MARC/XML Bibliographic records
:   to RDF conforming to the BIBFRAME model.  Outputs RDF/XML,
:   N-triples, or JSON.
:
:   @author Andreas Trawoeger (atrawog@hexaplant.com)
:   @since November 16, 2016
:   @version 0.1
:)

(: IMPORTED MODULES :)
import module namespace http            =   "http://zorba.io/modules/http-client";
import module namespace file            =   "http://expath.org/ns/file";
import module namespace parsexml        =   "http://zorba.io/modules/xml";
import schema namespace parseoptions    =   "http://zorba.io/modules/xml-options";

(: NAMESPACES :)
declare namespace marcxml       = "http://www.loc.gov/MARC21/slim";
declare namespace rdf           = "http://www.w3.org/1999/02/22-rdf-syntax-ns#";
declare namespace rdfs          = "http://www.w3.org/2000/01/rdf-schema#";

declare namespace bf            = "http://bibframe.org/vocab/";
declare namespace madsrdf       = "http://www.loc.gov/mads/rdf/v1#";
declare namespace relators      = "http://id.loc.gov/vocabulary/relators/";
declare namespace identifiers   = "http://id.loc.gov/vocabulary/identifiers/";
declare namespace notes         = "http://id.loc.gov/vocabulary/notes/";

declare namespace an = "http://zorba.io/annotations";
declare namespace httpexpath = "http://expath.org/ns/http-client";
declare namespace output = "http://www.w3.org/2010/xslt-xquery-serialization";

declare namespace log           = "info:lc/marc2bibframe/logging#";
declare namespace err           = "http://www.w3.org/2005/xqt-errors";
declare namespace zerror        = "http://zorba.io/errors";

(:~
:   This variable is for the MARCXML location - externally defined.
:)
declare variable $aseqxmluri as xs:string external;


<collection xmlns="http://www.loc.gov/MARC21/slim"
xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
xsi:schemaLocation="http://www.loc.gov/standards/marcxml/schema/MARC21slim.xsd">

{
let $aseqxml := doc($aseqxmluri)
for $record in $aseqxml/collection[*]/record[*]
  let $leader := $record/leader/text()
  let $cf001 := $record/datafield[@tag="001" and @ind1=" " and @ind2=" "]/subfield[@code="a"]/text()
  let $cf005 := $record/datafield[@tag="003" and @ind1=" " and @ind2=" "]/subfield[@code="a"]/text()
  return
  <record type="Bibliographic" >
  <leader>{$leader}</leader>
  <controlfield tag="001">{$cf001}</controlfield>
  <controlfield tag="005">{$cf005}</controlfield>
  </record>
}
</collection>
