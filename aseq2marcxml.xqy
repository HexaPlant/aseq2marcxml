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

declare namespace mtools       	= "https://github.com/HexaPlant/aseq2marcxml";

(:~
:   This variable is for the MARCXML location - externally defined.
:)
declare variable $aseqxmluri as xs:string external;

declare function mtools:controlfield($tag as xs:string,$value as xs:string)
as element()* {
    element {"controlfield"} { attribute tag {$tag}, $value}
};

declare function mtools:subfield($code as xs:string,$value as xs:string)
as element()* {
    element {"subfield"} { attribute code {$code}, $value}
};

declare function mtools:datafield($tag as xs:string,$ind1 as xs:string,$ind2 as xs:string,$value as element()*)
as element()* {
    element {"datafield"} { attribute tag {$tag}, attribute ind1 {$ind1}, attribute ind2 {$ind2}, $value}
};

declare function mtools:choosenotempty($s1 as xs:string*, $s2 as xs:string*)
as xs:string {
    if ($s1)
      then  $s1
      else  $s2
    };

<collection xmlns="http://www.loc.gov/MARC21/slim"
xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
xsi:schemaLocation="http://www.loc.gov/standards/marcxml/schema/MARC21slim.xsd">

{
let $aseqxml := doc($aseqxmluri)

let $controlfieldMap:=<controlfieldMap>
  <datafield tag="001" ind1=" " ind2=" " code="a"  m21tag="001"/>
</controlfieldMap>

let $datafieldMap:=<datafieldMap>
  <datafield tag="034" ind1=" " m21tag="034" m21ind1="1" m21ind2="#"/>
  <datafield tag="331" ind1=" " m21tag="245" m21ind1="0" m21ind2="0"/>
</datafieldMap>

let $subfieldMap:=<subfieldMap>
</subfieldMap>

for $record in $aseqxml/collection[*]/record[*]
  return
  <record type="Bibliographic" >
    {$record/leader}
    {
      for $datafield in $record/datafield
        let $tag:={data($datafield/@tag)}
        let $ind1:={data($datafield/@ind1)}
        let $m21tag:={data($datafieldMap/datafield[@tag=$tag and @ind1=$ind1]/@m21tag)}
        let $m21ind1:={data($datafieldMap/datafield[@tag=$tag and @ind1=$ind1]/@m21ind1)}
        let $m21ind2:={data($datafieldMap/datafield[@tag=$tag and @ind1=$ind1]/@m21ind2)}
        for $subfield in $datafield/subfield
          let $code:= {data($subfield/@code)}
          let $value:=$subfield/text()
          let $m21subfieldcode:= {data($subfieldMap/datafield[@tag=$tag and @ind1=$ind1 and @code=$code]/@m21code)}
          let $m21code := mtools:choosenotempty($m21subfieldcode,$code)
          let $m21subfield:=mtools:subfield({$m21code},{$value})

          return
            if ({$m21tag}) then
              mtools:datafield({$m21tag},{$m21ind1},{$m21ind2},{$m21subfield})
            else
              {}
    }
  </record>
}
</collection>
