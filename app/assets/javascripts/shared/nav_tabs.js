$('.nav-link').on('click', function(event) {

    $(this).parent().addClass('active');

    console.log($(this).parent());

    event.target.addClass('active')
});
