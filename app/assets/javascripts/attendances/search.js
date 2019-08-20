function bindAttendanceSearchEvent() {
    $('.search-attendance').on('click', function(event) {
        const pending = $('#pending').is(':checked');
        const accepted = $('#accepted').is(':checked');
        const paid = $('#paid').is(':checked');
        const confirmed = $('#confirmed').is(':checked');
        const showedIn = $('#showed_in').is(':checked');
        const cancelled = $('#cancelled').is(':checked');

        const searchText = $('#search').val();
        const eventId = $('#event_id').val();

        jQuery.ajax({
            url: `/events/${eventId}/attendances/search`,
            type: "GET",
            data: `search=${searchText}&pending=${pending}&accepted=${accepted}&paid=${paid}&confirmed=${confirmed}&showed_in=${showedIn}&cancelled=${cancelled}`
        });
    })
}
