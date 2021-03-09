# Slips Notices Report

This report provides general notice statistics, including:

-  notice type
-  notice description
-  notice delivery means (print, email, sms)
-  date of notice
-  note status (delivered or failure)
-  patron group
-  notice sender: library, department, service point, etc.  

If unaggregated, the report could also include recipient information. The report will have a filter on date, patron group, and type of notice.

The data in mod-email id limited because it's only the log from the SMTP server. It does not capture errors on the FOLIO processing
side of notices. Currently, location is not available. Status is either delivered or failure.

Note: the LDP does not currently ingest mod-email. Can start with what's available in circulation.

See also: 

<https://wiki.folio.org/display/RPT/RA-Slips+Notices+Cluster+Prototype-+In+Progress>    
<https://issues.folio.org/browse/UXPROD-2032>
<https://wiki.folio.org/display/FOLIOtips/How+to+use+FOLIO+APIs+to+query+emails+sent+to+patrons>
<https://wiki.folio.org/display/FOLIOtips/How+to+Configure+Patron+Notices>
<https://docs.google.com/document/d/1oMN1Jv18auepK8cuobnuYCiAENMr67JDnQQ0a9txpTc/edit#heading=h.9hpv3b725j1t>




Example report:

| Day notice sent | CIRC\_GROUP\_NAME | Total overdue notices sent | 5 | 9 | 11 | 13 | 15 | 17 | 19 | 21 | 23 |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| 02/19/2020 | Africana Circ Group | 1 | 1 |  |  |  |  |  |  |  |  |
| 02/19/2020 | Annex Circ Group | 105 |  |  |  |  |  | 105 |  |  |  |
| 02/19/2020 | ILR Circ Group | 2 |  |  | 1 |  |  |  |  |  | 1 |