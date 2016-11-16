xquery version "1.0";

(:
doc("woldan.xml")/collection/record
doc("woldan.xml")/collection/record/datafield/@tag
doc("woldan.xml")/collection/child::record/child::datafield/@tag
doc("woldan.xml")/collection/record/datafield[@tag="001"]
doc("woldan.xml")/collection/record/datafield[@tag="001" and @ind1=" " and @ind2=" "]/subfield[@code="a"]

:)

(:
for $collection in doc('./woldan.xml')
  for $record in $collection/record
    return
    <tst> {$record} </tst>
:)

<collection xmlns="http://www.loc.gov/MARC21/slim"
xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
xsi:schemaLocation="http://www.loc.gov/MARC21/slim
http://www.loc.gov/standards/marcxml/schema/MARC21slim.xsd">

{
let $aseq := doc("woldan.xml")
for $record in $aseq/collection[*]/record[*]

  let $cf001 := $record/datafield[@tag="001" and @ind1=" " and @ind2=" "]/subfield[@code="a"]/text()
  return
  <record xmlns="http://www.loc.gov/MARC21/slim" type="Bibliographic" >
  <controlfield tag="001">{$cf001}</controlfield>
  </record>
}
</collection>
