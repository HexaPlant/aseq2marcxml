xquery version "3.0";

(:
:   Module Name: ASEQ/XML to MARC/XML using Zorba
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
:   Transforms Aleph ASEQ/XML
:   to MARC/XML Bibliographic records
:
:   @author Andreas Trawoeger (atrawog@hexaplant.com)
:   @since November 16, 2016
:   @version 0.1
:)

(: IMPORTED MODULES :)
declare namespace mtools       	= "https://github.com/HexaPlant/aseq2marcxml";

(:~
:   This variable is for the MARCXML location - externally defined.
:)
declare variable $aseqxmluri as xs:string external;

declare function mtools:createControlfield($tag as xs:string,$value as xs:string)
as element()? {
    element {"controlfield"} { attribute tag {$tag}, $value}
};

declare function mtools:createSubfield($code as xs:string,$value as xs:string)
as element()? {
    element {"subfield"} { attribute code {$code}, $value}
};

declare function mtools:createDatafield($tag as xs:string,$ind1 as xs:string,$ind2 as xs:string,$value as element()*)
as element()? {
    element {"datafield"} { attribute tag {$tag}, attribute ind1 {$ind1}, attribute ind2 {$ind2}, $value}
};

declare function mtools:chooseNotEmpty($s1 as xs:string*, $s2 as xs:string*)
as xs:string {
    if ($s1)
      then  $s1
      else  $s2
    };

declare function mtools:createField($m21tag as xs:string*,$m21ind1 as xs:string*,$m21ind2 as xs:string*,$m21code as xs:string*,$code as xs:string*, $value as xs:string*)
as element()? {
  if ($m21tag and $m21ind1 and $m21ind2 and $m21code ) then
    mtools:createDatafield({$m21tag},{$m21ind1},{$m21ind2},mtools:createSubfield({$m21code},{$value}))
  else if ($m21tag and $m21ind1 and $m21ind2 and $code ) then
    mtools:createDatafield({$m21tag},{$m21ind1},{$m21ind2},mtools:createSubfield({$code},{$value}))
  else if ($m21tag) then
    mtools:createControlfield({$m21tag},{$value})
  else
    {}
};

declare function mtools:convertSubfields($tag as xs:string*,$ind1 as xs:string*,$datafieldMap as element()*,$subfields as element()*) as element()*{
  for $subfield in $subfields
    let $code:= {data($subfield/@code)}
    let $value:=$subfield/text()

    let $m21tag:={data($datafieldMap[@tag=$tag and @ind1=$ind1]/@m21tag)}
    let $m21ind1:={data($datafieldMap[@tag=$tag and @ind1=$ind1]/@m21ind1)}
    let $m21ind2:={data($datafieldMap[@tag=$tag and @ind1=$ind1]/@m21ind2)}
    let $m21code := {data($datafieldMap[@tag=$tag and @ind1=$ind1 and @code=$code]/@m21code)}
    return
      mtools:createField({$m21tag},{$m21ind1},{$m21ind2},{$m21code},{$code},{$value})
};

(: return a deep copy of  the element and all sub elements :)
declare function mtools:copy($element as element()) as element() {
   element {node-name($element)}
      {$element/@*,
          for $child in $element/node()
              return
               if ($child instance of element())
                 then mtools:copy($child)
                 else $child
      }
};

<collection xmlns="http://www.loc.gov/MARC21/slim"
xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
xsi:schemaLocation="http://www.loc.gov/standards/marcxml/schema/MARC21slim.xsd">

{
let $aseqxml := doc($aseqxmluri)

let $datafieldMap:=<datafieldMap>
  <datafield tag="001" ind1=" " m21tag="001"/>
  <datafield tag="002" ind1="a" m21tag="002"/>
  <datafield tag="002" ind1="b" m21tag="003"/>
  <datafield tag="003" ind1=" " m21tag="005"/>
  <datafield tag="034" ind1=" " code="a" m21tag="034" m21ind1="1" m21ind2="#" m21code="testa"/>
  <datafield tag="331" ind1=" " m21tag="245" m21ind1="0" m21ind2="0"/>
</datafieldMap>

for $record in $aseqxml/collection/record
  return
  <record type="Bibliographic" >
    {$record/leader}
    {
      for $datafield in $record/datafield
        let $tag:={data($datafield/@tag)}
        let $ind1:={data($datafield/@ind1)}
        let $m21subfields:=mtools:convertSubfields($tag,$ind1,$datafieldMap/datafield,$datafield/subfield)
        return
          $m21subfields
    }
  </record>
}
</collection>
