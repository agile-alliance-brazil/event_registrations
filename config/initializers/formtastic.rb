begin
  Formtastic::FormBuilder.escape_html_entities_in_hints_and_labels = false
  Formtastic::FormBuilder.action_class_finder = Formtastic::ActionClassFinder
  Formtastic::FormBuilder.input_class_finder = Formtastic::InputClassFinder
rescue LoadError
  Rails.logger.error("Formstatic isn't loaded! Either remove this initializer or ensure Formtastic is loaded")
end
