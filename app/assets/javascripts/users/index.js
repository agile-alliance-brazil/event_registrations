function submitSearch() {
  var searchText = $('#search').val();
  var role = $('#roles').val();

  var roleIndex = -1;

  if (role == 'guest') {
    roleIndex = 0;
  } else if (role == 'admin') {
    roleIndex = 1;
  } else if (role == 'organizer') {
    roleIndex = 2;
  } else if (role == 'admin e organizer') {
    roleIndex = 3;
  }

  $.get('/users', { search: searchText, role_index: roleIndex } );
}
