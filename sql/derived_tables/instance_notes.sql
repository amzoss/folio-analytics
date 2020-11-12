DROP TABLE IF EXISTS local.instance_notes;

-- Create a local table for notes in instance records that includes the type id and name. Here note can be either public or for staff.
CREATE TABLE local.instance_notes AS
SELECT
    instances.id AS instance_id,
    instances.hrid AS instance_hrid,
    json_extract_path_text(notes.data, 'instanceNoteTypeId') AS note_type_id,
    instance_note_types.name AS note_type_name,
    json_extract_path_text(notes.data, 'note') AS note,
    json_extract_path_text(notes.data, 'staffOnly')::boolean AS staff_only
FROM
    inventory_instances AS instances
    CROSS JOIN json_array_elements(json_extract_path(data, 'notes')) AS notes (data)
    LEFT JOIN inventory_instance_note_types AS instance_note_types ON json_extract_path_text(notes.data, 'instanceNoteTypeId') = instance_note_types.id;

CREATE INDEX ON local.instance_notes (instance_id);

CREATE INDEX ON local.instance_notes (instance_hrid);

CREATE INDEX ON local.instance_notes (note_type_id);

CREATE INDEX ON local.instance_notes (note_type_name);

CREATE INDEX ON local.instance_notes (note);

CREATE INDEX ON local.instance_notes (staff_only);

