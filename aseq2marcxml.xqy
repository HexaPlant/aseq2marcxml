xquery version "3.0";
declare default element namespace "http://www.loc.gov/MARC21/slim";

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

declare function mtools:convertSubfields($tag as xs:string*,$ind1 as xs:string*,$subfields as element()*,$datafieldMap as element()*) as element()*{
  for $subfield in $subfields
    let $code:= {data($subfield/@code)}
    let $subvalue:=$subfield/text()

    let $m21tag:={data($datafieldMap[@tag=$tag and @ind1=$ind1]/@m21tag)}[1]
    let $m21ind1:={data($datafieldMap[@tag=$tag and @ind1=$ind1]/@m21ind1)}[1]
    let $m21ind2:={data($datafieldMap[@tag=$tag and @ind1=$ind1]/@m21ind2)}[1]
    let $m21code := {data($datafieldMap[@tag=$tag and @ind1=$ind1 and @code=$code]/@m21code)}[1]
    return
      mtools:createSubfield({mtools:chooseNotEmpty($m21code,$code)},{$subvalue})
};

declare function mtools:createField($m21tag as xs:string*,$m21ind1 as xs:string*,$m21ind2 as xs:string*,$subcode_a as xs:string*,$m21subfields as element()*)
as element()? {
  if ($m21tag and $m21ind1 and $m21ind2) then
    mtools:createDatafield({$m21tag},{$m21ind1},{$m21ind2},{$m21subfields})
  else if ($m21tag and $subcode_a) then
    mtools:createControlfield({$m21tag},{$subcode_a})
  else
    {}
};

declare function mtools:convertDatafield($datafield as element(),$subfields as element()*,$datafieldMap as element()*) as element()*{
  let $tag:={data($datafield/@tag)}
  let $ind1:={data($datafield/@ind1)}
  let $subcode_a:=$subfields[@code="a"]/text()
  let $m21tag:={data($datafieldMap[@tag=$tag and @ind1=$ind1]/@m21tag)}[1]
  let $m21ind1:={data($datafieldMap[@tag=$tag and @ind1=$ind1]/@m21ind1)}[1]
  let $m21ind2:={data($datafieldMap[@tag=$tag and @ind1=$ind1]/@m21ind2)}[1]

  let $m21subfields:=mtools:convertSubfields($tag,$ind1,$subfields,$datafieldMap)

  return
      (: element {"debug"} { attribute tag {$tag}, attribute ind1 {$ind1}, attribute m21tag  {$m21tag}, attribute m21ind1  {$m21ind1}, attribute m21ind2  {$m21ind2}, $subcode_a} :)
    mtools:createField($m21tag,$m21ind1,$m21ind2,$subcode_a,$m21subfields)
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
  <datafield tag="010" ind1=" " code="a" m21tag="773" m21ind1="0" m21ind2="#" m21code="w"/>
  <datafield tag="034" ind1=" " m21tag="034" m21ind1="1" m21ind2="#" />
  <datafield tag="036" ind1="a" code="a" m21tag="044" m21ind1="#" m21ind2="#" m21code="c"/>
  <datafield tag="037" ind1="b" code="a" m21tag="041" m21ind1="#" m21ind2="7" m21code="a"/>
  <datafield tag="064" ind1="a" code="a" m21tag="655" m21ind1="#" m21ind2="7" m21code="a"/>
  <datafield tag="064" ind1="9" code="" m21tag="655" m21ind1="#" m21ind2="7" m21code="0"/>
  <datafield tag="089" ind1=" " m21tag="245" m21ind1="0" m21ind2="0"/>
  <datafield tag="090" ind1=" " code="" m21tag="773" m21ind1="0" m21ind2="#" m21code="q"/>
  <datafield tag="100" ind1=" " code="p" m21tag="100" m21ind1="1" m21ind2="#" m21code="a"/>
  <datafield tag="200" ind1=" " code="k" m21tag="110" m21ind1="2" m21ind2="#" m21code="a"/>
  <datafield tag="200" ind1=" " code="h" m21tag="110" m21ind1="2" m21ind2="#" m21code="g"/>
  <datafield tag="200" ind1=" " code="9" m21tag="110" m21ind1="2" m21ind2="#" m21code="0"/>
  <datafield tag="200" ind1="b" code="k" m21tag="110" m21ind1="2" m21ind2="#" m21code="a"/>
  <datafield tag="200" ind1="b" code="h" m21tag="110" m21ind1="2" m21ind2="#" m21code="g"/>
  <datafield tag="200" ind1="b" code="9" m21tag="110" m21ind1="2" m21ind2="#" m21code="0"/>
  <datafield tag="331" ind1=" " m21tag="245" m21ind1="0" m21ind2="0"/>
  <datafield tag="331" ind1="_" code="a" m21tag="765" m21ind1="0" m21ind2="#" m21code="t"/>
  <datafield tag="370" ind1="a" m21tag="246" m21ind1="0" m21ind2="3"/>
  <datafield tag="403" ind1=" " m21tag="250" m21ind1="#" m21ind2="#"/>
  <datafield tag="407" ind1=" " m21tag="255" m21ind1="#" m21ind2="#"/>
  <datafield tag="419" ind1=" " m21tag="264" m21ind1="#" m21ind2="1"/>
  <datafield tag="419" ind1="c" m21tag="264" m21ind1="#" m21ind2="3"/>
  <datafield tag="433" ind1=" " m21tag="300" m21ind1="#" m21ind2="#"/>
  <datafield tag="590" ind1=" " code="a" m21tag="773" m21ind1="#" m21ind2="#" m21code="t"/>
  <datafield tag="594" ind1=" " code="a" m21tag="773" m21ind1="#" m21ind2="#" m21code="d"/>
  <datafield tag="595" ind1=" " code="a" m21tag="773" m21ind1="#" m21ind2="#" m21code="d"/>
  <datafield tag="596" ind1="a" code="a" m21tag="773" m21ind1="#" m21ind2="#" m21code="g"/>
  <datafield tag="599" ind1=" " code="a" m21tag="773" m21ind1="#" m21ind2="#" m21code="w"/>
  <datafield tag="676" ind1=" " code="g" m21tag="751" m21ind1="#" m21ind2="#" m21code="a"/>
  <datafield tag="676" ind1=" " code="9" m21tag="751" m21ind1="#" m21ind2="#" m21code="0"/>
  <datafield tag="676" ind1=" " code=" " m21tag="751" m21ind1="#" m21ind2="#" m21code="2"/>
  <datafield tag="677" ind1=" " code="p" m21tag="700" m21ind1="1" m21ind2="#" m21code="a"/>
  <datafield tag="677" ind1=" " code="9" m21tag="700" m21ind1="1" m21ind2="#" m21code="0"/>
  <datafield tag="677" ind1=" " code="4" m21tag="700" m21ind1="1" m21ind2="#" m21code="4"/>
  <datafield tag="677" ind1=" " code="k" m21tag="700" m21ind1="1" m21ind2="#" m21code="a"/>
  <datafield tag="677" ind1=" " code="9" m21tag="700" m21ind1="1" m21ind2="#" m21code="0"/>
  <datafield tag="677" ind1=" " code="4" m21tag="700" m21ind1="1" m21ind2="#" m21code="4"/>
</datafieldMap>

for $record in $aseqxml/collection/record
  return
  <record type="Bibliographic" >
    {$record/leader}
    {
      for $datafield in $record/datafield
        return
          mtools:convertDatafield($datafield,$datafield/subfield, $datafieldMap/datafield)
    }
  </record>
}
</collection>
