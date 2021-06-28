function bindClickToLoadUser() {
    $('.user-select').on('change', function(){
        const eventId = $('#event_id').val();
        const userId = $('.user-select').val();

        jQuery.ajax({
            url: `/events/${eventId}/attendances/user_info.js`,
            type: "GET",
            data: `&user_id=${userId}`
        });
    });
}
