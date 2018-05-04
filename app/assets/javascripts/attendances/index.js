function submitSearch(event_id) {
    var pending = $('#pending').is(':checked');
    var accepted = $('#accepted').is(':checked');
    var paid = $('#paid').is(':checked');
    var confirmed = $('#confirmed').is(':checked');
    var showed_in = $('#showed_in').is(':checked');
    var cancelled = $('#cancelled').is(':checked');

    var searchText = $('#search').val();

    $.get('/events/' + event_id + '/attendances/search', { event_id: event_id, search: searchText, pending: pending, accepted: accepted, paid: paid, confirmed: confirmed, showed_in: showed_in, cancelled: cancelled } );
}
