# encoding: UTF-8
begin
  Formtastic::FormBuilder.escape_html_entities_in_hints_and_labels = false
  Formtastic::FormBuilder.action_class_finder = Formtastic::ActionClassFinder
  Formtastic::FormBuilder.input_class_finder = Formtastic::InputClassFinder
rescue LoadError
end
