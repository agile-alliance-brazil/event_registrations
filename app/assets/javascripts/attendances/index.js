function submitSearch(event_id) {
    const pending = $('#pending').is(':checked');
    const accepted = $('#accepted').is(':checked');
    const paid = $('#paid').is(':checked');
    const confirmed = $('#confirmed').is(':checked');
    const showed_in = $('#showed_in').is(':checked');
    const cancelled = $('#cancelled').is(':checked');

    const searchText = $('#search').val();

    $.get('/events/' + event_id + '/attendances/search', { event_id: event_id, search: searchText, pending: pending, accepted: accepted, paid: paid, confirmed: confirmed, showed_in: showed_in, cancelled: cancelled } );
}
