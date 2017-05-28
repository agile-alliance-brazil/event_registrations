function submitSearch(event_id) {
    var pending = $('#pending').is(':checked');
    var accepted = $('#accepted').is(':checked');
    var paid = $('#paid').is(':checked');
    var cancelled = $('#cancelled').is(':checked');

    var searchText = $('#search').val();

    console.log(event_id);
    console.log(searchText);

    $.get('/attendances/search', { event_id: event_id, search: searchText, pending: pending, accepted: accepted, paid: paid, cancelled: cancelled } );
}
