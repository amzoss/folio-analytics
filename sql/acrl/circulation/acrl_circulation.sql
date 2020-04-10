/* FIELDS TO INCLUDE:
Parameters
    date_range
Loans table
    loan_date
Groups table
    patron_group_name
Material Types table
    material_type_name
Locations table
    perm_location_name
    temp_location_name
    effective_location_name
Institutions table
    institution_name
Campuses table
    campus_name
Libraries table
    library_name

Aggregation: none

Filters:
    start_date (for loan_date)
    end_date (for loan_date)
    material_type_filter
    items_permament_location_filter
    items_temporary_location_filter
    items_effective_location_filter
    institution_filter
    campus_filter
    library_filter
*/
WITH parameters AS (
    SELECT
        /* Choose a start and end date for the loans period */
        '2000-01-01' :: DATE AS start_date,
        '2021-01-01' :: DATE AS end_date,
        /* Fill in a material type name, or leave blank for all types */
        '' :: VARCHAR AS material_type_filter,
        /* Fill in a location name, or leave blank for all locations */
        '' :: VARCHAR AS items_permanent_location_filter, --Online, Annex, Main Library
        '' :: VARCHAR AS items_temporary_location_filter, --Online, Annex, Main Library
        '' :: VARCHAR AS items_effective_location_filter, --Online, Annex, Main Library
        '' :: VARCHAR AS institution_filter, -- 'KÃ¸benhavns Universitet','Montoya College'
        '' :: VARCHAR AS campus_filter, -- 'Main Campus','City Campus','Online'
        '' :: VARCHAR AS library_filter -- 'Datalogisk Institut','Adelaide Library'
),
--SUB-QUERIES
location_filtering AS (
    SELECT
        i.id AS item_id,
        itpl."name" AS perm_location_name,
        ittl."name" AS temp_location_name,
        itel."name" AS effective_location_name,
        inst."name" AS institution_name,
        cmp."name" AS campus_name,
        lib."name" AS library_name
    FROM inventory_items AS i
    LEFT JOIN inventory_locations AS itpl
        ON i.permanent_location_id = itpl.id
    LEFT JOIN inventory_locations AS ittl
        ON i.temporary_location_id = ittl.id
    LEFT JOIN inventory_locations AS itel
        ON i.effective_location_id = itel.id
    LEFT JOIN inventory_libraries AS lib
        ON itpl.library_id = lib.id
    LEFT JOIN inventory_campuses AS cmp
        ON itpl.campus_id = cmp.id
    LEFT JOIN inventory_institutions AS inst
        ON itpl.institution_id = inst.id
	WHERE
    	(itpl."name" = (SELECT items_permanent_location_filter FROM parameters)
    	       OR '' = (SELECT items_permanent_location_filter FROM parameters))
    AND (ittl."name" = (SELECT items_temporary_location_filter FROM parameters)
    	       OR '' = (SELECT items_temporary_location_filter FROM parameters))
    AND (itel."name" = (SELECT items_effective_location_filter FROM parameters)
    	       OR '' = (SELECT items_effective_location_filter FROM parameters))
    AND (lib."name" = (SELECT library_filter FROM parameters)
        	   OR '' = (SELECT library_filter FROM parameters))
	AND (cmp."name" = (SELECT campus_filter FROM parameters)
    	       OR '' = (SELECT campus_filter FROM parameters))
	AND (inst."name" = (SELECT institution_filter FROM parameters)
        	   OR '' = (SELECT institution_filter FROM parameters))
),
loan_details AS (
    SELECT
        l.loan_date,
        l.due_date AS loan_due_date,
        l.return_date AS loan_return_date,
        l.item_status AS loan_status,
        l.item_id,
        l.id AS loan_id,
        l.patron_group_id_at_checkout,
        i.material_type_id,
        mt.name AS material_type_name,
        g.group AS patron_group_name,
        lp.name AS loan_policy_name,
        plt.name AS permanent_loan_type_name,
        tlt.name AS temporary_loan_type_name,
        location_filtering.temp_location_name,
        location_filtering.perm_location_name,
        location_filtering.effective_location_name,
        location_filtering.institution_name,
        location_filtering.campus_name,
        location_filtering.library_name
    FROM circulation_loans AS l
    LEFT JOIN inventory_items AS i
        ON l.item_id=i.id
    LEFT JOIN circulation_loan_policies AS lp
        ON l.loan_policy_id=lp.id
    LEFT JOIN inventory_loan_types AS plt
        ON i.permanent_loan_type_id=plt.id
    LEFT JOIN inventory_loan_types AS tlt
        ON i.temporary_loan_type_id=tlt.id
    LEFT JOIN inventory_material_types AS mt
        ON i.material_type_id=mt.id
    LEFT JOIN user_groups AS g
        ON l.patron_group_id_at_checkout=g.id
-- note INNER JOIN needed for applying the location filtering
    INNER JOIN location_filtering
        ON l.item_id= location_filtering.item_id
)
--MAIN QUERY
SELECT
    (SELECT start_date :: VARCHAR FROM parameters) ||
        ' to ' :: VARCHAR ||
        (SELECT end_date :: VARCHAR FROM parameters) AS date_range,
    loan_date,
    patron_group_name,
    material_type_name,
    perm_location_name,
    temp_location_name,
    effective_location_name,
    institution_name,
    campus_name,
    library_name
FROM loan_details
WHERE
    loan_date >= (SELECT start_date FROM parameters)
AND loan_date < (SELECT end_date FROM parameters)
AND (
    material_type_name = (SELECT material_type_filter FROM parameters)
    OR '' = (SELECT material_type_filter FROM parameters)
);
