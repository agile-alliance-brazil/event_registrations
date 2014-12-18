# encoding: UTF-8
begin
  Formtastic::FormBuilder.escape_html_entities_in_hints_and_labels = false
rescue LoadError
end
