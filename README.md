# aseq2marcxml
Transform Aleph ASEQ Bibliographic records into MARCXML and BIBFRAME format using Zorba and XQuery.

#Example
zorba  -i -f -q aseq2marcxml.xqy  -e aseqxmluri:="./samples/woldan_record_aseq.xml" |  tee ./samples/woldan_record_marc.xml
￼zorba  -i -f -q markxml2bibframe.xqy -e marcxmluri:="./samples/woldan_record_marc.xml" -e writelog:="true" -e logdir:="./log/" -e baseuri
:="http://permalink.obvsg.at/" | tee samples/woldan_record_marc.rdf

zorba  -i -f -q aseq2marcxml.xqy  -e aseqxmluri:="./samples/woldan_aseq.xml" |  tee ./samples/woldan_marc.xml
￼zorba  -i -f -q markxml2bibframe.xqy -e marcxmluri:="./samples/woldan_marc.xml" -e writelog:="true" -e logdir:="./log/" -e baseuri
:="http://permalink.obvsg.at/" | tee samples/woldan_marc.rdf
