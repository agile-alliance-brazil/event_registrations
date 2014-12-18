//= require jquery
//= require jquery_ujs
//= require_self
//= require_tree .

(function($) {
  $.fn.bindSelectUpdated = function() {
    return this.each(function() {
      $(this).change(function() {$(this).trigger('updated')});
      $(this).keyup(function() {$(this).trigger('updated')});
    })
  }
  $(document).ready(function() {
    $('a').filter(function(index, element) {
      return $(element).data('function') !== undefined;
    }).click(function(event) {
      $.globalEval($(event.currentTarget).data('function'));
      return false;
    });
  });
})(jQuery);
