--DROP TABLE IF EXISTS folio_reporting.notice_policies;

-- Create table normalizing data from circulation_patron_notice_policies
--CREATE TABLE folio_reporting.notice_policies AS
WITH loan_list AS (
    SELECT
        policies.id AS policy_id,
        policies.name AS policy_name,
        policies.description AS policy_description,
        policies.active AS policy_active,
        'loan'::varchar AS notice_circ_event_type, --loan, request, fee/fine
        json_extract_path_text(loanNotice.data, 'name') AS notice_name,
        json_extract_path_text(loanNotice.data, 'templateId') AS notice_template_id,
        json_extract_path_text(loanNotice.data, 'templateName') AS notice_template_name,
        json_extract_path_text(loanNotice.data, 'format') AS notice_format,
        json_extract_path_text(loanNotice.data, 'frequency') AS notice_frequency,
        json_extract_path_text(loanNotice.data, 'realTime') AS notice_realTime,
        json_extract_path_text(loanNotice.data, 'sendOptions','sendHow') AS notice_send_how,
        json_extract_path_text(loanNotice.data, 'sendOptions', 'sendWhen') AS notice_send_when,
        json_extract_path_text(loanNotice.data, 'sendOptions','sendBy') AS notice_send_by, -- object??
        json_extract_path_text(loanNotice.data, 'sendOptions', 'sendEvery') AS notice_send_every -- object??
    FROM
        circulation_patron_notice_policies AS policies
        CROSS JOIN json_array_elements(json_extract_path(policies.data, 'loanNotices')) AS loanNotice(data)
),
fee_fine_list AS (
    SELECT
        policies.id AS policy_id,
        policies.name AS policy_name,
        policies.description AS policy_description,
        policies.active AS policy_active,
        'fee/fine'::varchar AS notice_circ_event_type, --loan, request, fee/fine
        json_extract_path_text(feeFineNotice.data, 'name') AS notice_name,
        json_extract_path_text(feeFineNotice.data, 'templateId') AS notice_template_id,
        json_extract_path_text(feeFineNotice.data, 'templateName') AS notice_template_name,
        json_extract_path_text(feeFineNotice.data, 'format') AS notice_format,
        json_extract_path_text(feeFineNotice.data, 'frequency') AS notice_frequency,
        json_extract_path_text(feeFineNotice.data, 'realTime') AS notice_realTime,
        json_extract_path_text(feeFineNotice.data, 'sendOptions','sendHow') AS notice_send_how,
        json_extract_path_text(feeFineNotice.data, 'sendOptions', 'sendWhen') AS notice_send_when,
        json_extract_path_text(feeFineNotice.data, 'sendOptions','sendBy') AS notice_send_by, -- object??
        json_extract_path_text(feeFineNotice.data, 'sendOptions', 'sendEvery') AS notice_send_every -- object??
    FROM
        circulation_patron_notice_policies AS policies
        CROSS JOIN json_array_elements(json_extract_path(policies.data, 'feeFineNotices')) AS feeFineNotice(data)
),
request_list AS (
    SELECT
        policies.id AS policy_id,
        policies.name AS policy_name,
        policies.description AS policy_description,
        policies.active AS policy_active,
        'request'::varchar AS notice_circ_event_type, --loan, request, fee/fine
        json_extract_path_text(requestNotice.data, 'name') AS notice_name,
        json_extract_path_text(requestNotice.data, 'templateId') AS notice_template_id,
        json_extract_path_text(requestNotice.data, 'templateName') AS notice_template_name,
        json_extract_path_text(requestNotice.data, 'format') AS notice_format,
        json_extract_path_text(requestNotice.data, 'frequency') AS notice_frequency,
        json_extract_path_text(requestNotice.data, 'realTime') AS notice_realTime,
        json_extract_path_text(requestNotice.data, 'sendOptions','sendHow') AS notice_send_how,
        json_extract_path_text(requestNotice.data, 'sendOptions', 'sendWhen') AS notice_send_when,
        json_extract_path_text(requestNotice.data, 'sendOptions','sendBy') AS notice_send_by, -- object??
        json_extract_path_text(requestNotice.data, 'sendOptions', 'sendEvery') AS notice_send_every -- object??
    FROM
        circulation_patron_notice_policies AS policies
        CROSS JOIN json_array_elements(json_extract_path(policies.data, 'requestNotices')) AS requestNotice(data)
)
SELECT * FROM loan_list
UNION
SELECT * FROM fee_fine_list
UNION
SELECT * FROM request_list
;

CREATE INDEX ON folio_reporting.instance_publication (instance_id);

CREATE INDEX ON folio_reporting.instance_publication (instance_hrid);

CREATE INDEX ON folio_reporting.instance_publication (date_of_publication);

CREATE INDEX ON folio_reporting.instance_publication (place);

CREATE INDEX ON folio_reporting.instance_publication (publisher);

