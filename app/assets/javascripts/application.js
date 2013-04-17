//= require jquery
//= require jquery_ujs
//= require_self
//= require_tree .

jQuery.fn.bindSelectUpdated = function() {
  return this.each(function() {
    $(this).change(function() {$(this).trigger('updated')});
    $(this).keyup(function() {$(this).trigger('updated')});
  })
}
