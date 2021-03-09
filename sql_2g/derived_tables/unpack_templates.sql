SELECT 
    json_extract_path_text(jsonb::JSON,'id') AS template_id, 
    json_extract_path_text(jsonb::JSON,'description') AS template_description, 
    json_extract_path_text(jsonb::JSON,'outputFormats') AS template_output_formats, 
    json_extract_path_text(jsonb::JSON,'templateResolver') AS template_resolver, 
    json_extract_path_text(jsonb::JSON,'localizedTemplates','en','header') AS template_en_header, 
    json_extract_path_text(jsonb::JSON,'localizedTemplates','en','body') AS template_en_body 
FROM 
    folio_template_engine."template"
;    