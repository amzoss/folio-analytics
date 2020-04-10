/*FIELDS INCLUDED IN SAMPLE:
Items table	
	Item ID
	Item permanent location (filter)
	Item temporary location (filter)
	Item status (filter)
	Date range (filter)
	Item Transit destination service point name (filter)
	Item barcode
	Item material type ID
	Item call number
	Item holdings record ID
	Item volume number
	Item enumeration
	Item chronology
	Item copy number
	Item note
Loans table
	Loan ID
	Loan renewal count
	Loan item ID
	Loan item effective location at checkout
Material types table
	Material type ID
	Material type name
Holdings table
	Holdings ID
	Holdings Item permanent location (filter)
	Holdings Item temporary location (filter)
	Holdings shelving title
	Holdings instance ID
Locations table
	Location ID
	Location name
Instances table
	Instance ID
	Instance date of publication
	Instance catalogued date
Service points table
	Service points ID
	Service points name

FILTERS: item status type, item status date, location

AGGREGATION: number of loans for each item, loan renewal counts, sum of these two aggregations

Note: We are using item status 'In transit' to indicate that an item is missing.
You can set the date range to specify that it is older, closed loans with "In transit"
status that constitute missing items. 

TODO: make sure we're supposed to use item status from item instead of loans
TODO: think about item status more, maybe - this is looking for "In transit", but
      what about "Lost" or "Missing" (those are both mentioned in the prototype
Yes, take item status from loans, but should be same as one from items
*/

/* Change the lines below to adjust the date, item status, and location filters */
WITH parameters AS (
    SELECT
        '2000-01-01' :: DATE AS start_date,
        '2021-01-01' :: DATE AS end_date,
        'In transit' :: VARCHAR AS item_status_filter,
		---- Fill out one, leave others blank to filter by location or service point name ----
        '' ::VARCHAR AS items_permanent_location_filter, -- 'Main Library'
        '' ::VARCHAR AS items_temporary_location_filter, -- 'Annex'
        'Main Library' ::VARCHAR AS holdings_permanent_location_filter, -- 'Main Library'
        '' ::VARCHAR AS holdings_temporary_location_filter, -- 'Main Library'
        '' ::VARCHAR AS effective_location_filter, -- 'Main Library'
        '' ::VARCHAR AS in_transit_destination_service_point_filter -- 'Circ Desk 1'
        ),
---------- SUB-QUERIES/TABLES ----------
ranked_loans AS (
    SELECT 
        id,
        -- item_effective_location_at_check_out,
        json_extract_path_text(data, 'itemEffectiveLocationAtCheckOut') AS item_effective_location_at_check_out,
        return_date,
        item_id,
        checkout_service_point_id,
        checkin_service_point_id,
        item_status,
        rank() OVER (
            PARTITION BY item_id
            ORDER BY return_date DESC
        ) AS return_date_ranked
    FROM circulation_loans
    WHERE
	    item_status = (SELECT item_status_filter FROM parameters)
    AND return_date :: DATE >= (SELECT start_date FROM parameters)
    AND return_date :: DATE <  (SELECT end_date FROM parameters)    
)
SELECT
	(SELECT start_date :: VARCHAR FROM parameters) ||
        ' to ' :: VARCHAR ||
        (SELECT end_date :: VARCHAR FROM parameters) AS date_range,
	hploc.name AS holdings_permanent_location_name,
	htloc.name AS holdings_temporary_location_name,
	h.shelving_title,
	iploc.name AS items_permanent_location_name,
	itloc.name AS items_temporary_location_name,
	effloc.name AS items_effective_location_name,
	i.barcode,
	i.item_level_call_number,
	--i.volume,
	json_extract_path_text(i.data, 'volume') AS volume,
	i.enumeration,
	i.chronology,
	json_extract_path_text(i.data, 'notes', 'description') AS item_notes,
	'{ "copyNumbers": ' :: varchar || 
        COALESCE(json_extract_path_text(i.data, 'copyNumbers'), '[]' :: varchar) ||
		'}' :: varchar AS copy_numbers,
	l.item_status,
    cosp.name AS checkout_service_point_name,
    cisp.name AS checkin_service_point_name,
    ins.cataloged_date,
    json_extract_path_text(ins.data, 'publication', 'dateOfPulication') AS instance_publication_date,
    m.name AS material_type_name,
    itsp.name AS in_transit_destination_service_point_name,
    l2.num_loans + l2.num_renewals AS num_loans_and_renewals
FROM (
    SELECT
        id,
        holdings_record_id,
        permanent_location_id,
        temporary_location_id,
        in_transit_destination_service_point_id,
        barcode,
        material_type_id,
        item_level_call_number,
        --volume,
        enumeration,
        chronology,
        data
	FROM inventory_items	
) AS i
LEFT JOIN inventory_holdings AS h
	ON i.holdings_record_id = h.id
/* This should be pulling the latest loan for each item. Worth testing more. */
INNER JOIN (
	SELECT 
        id,
        item_effective_location_at_check_out,
        item_id,
        checkout_service_point_id,
        checkin_service_point_id,
        item_status
    FROM ranked_loans
    WHERE ranked_loans.return_date_ranked = 1
) AS l
	ON i.id = l.item_id 
LEFT JOIN inventory_instances AS ins
	ON h.instance_id = ins.id
LEFT JOIN inventory_material_types AS m
	ON i.material_type_id = m.id
LEFT JOIN inventory_service_points AS cosp 
	ON l.checkout_service_point_id=cosp.id 
LEFT JOIN inventory_service_points AS cisp 
	ON l.checkin_service_point_id=cisp.id 
-- using this makes sense if we're using item status of "in transit", but when
-- using loan's item status, will item have an in transit service point?
LEFT JOIN inventory_service_points AS itsp 
	ON i.in_transit_destination_service_point_id=itsp.id 
LEFT JOIN inventory_locations AS hploc
	ON h.permanent_location_id = hploc.id
--holdings temp locations not showing up in table yet, so have to pull from data	
--LEFT JOIN inventory_locations AS htloc
--	ON h.temporary_location_id = htloc.id
LEFT JOIN inventory_locations AS htloc
	ON json_extract_path_text(h.data, 'temporaryLocationId') = htloc.id
LEFT JOIN inventory_locations AS iploc
	ON i.permanent_location_id = iploc.id
LEFT JOIN inventory_locations AS itloc
	ON i.temporary_location_id = itloc.id
LEFT JOIN inventory_locations AS effloc
	ON l.item_effective_location_at_check_out = effloc.id
LEFT JOIN (
    SELECT
    	item_id,
        COUNT(id) AS num_loans,
        SUM(renewal_count) AS num_renewals
    FROM circulation_loans
    GROUP BY item_id
) AS l2
	ON i.id = l2.item_id
WHERE 
    /*choose only ONE of the statements below, to match with choice of location filter*/
    iploc.name = (SELECT items_permanent_location_filter FROM parameters)
    OR itloc.name = (SELECT items_temporary_location_filter FROM parameters)
    OR hploc.name = (SELECT holdings_permanent_location_filter FROM parameters)
    OR htloc.name = (SELECT holdings_temporary_location_filter FROM parameters)
    OR effloc.name = (SELECT effective_location_filter FROM parameters)
    OR itsp.name = (SELECT in_transit_destination_service_point_filter FROM parameters)
 ;

     	
   
