function removeOrganizer(user_email, event_id) {
  $.ajax({
    type: 'DELETE',
    url: '/events/' + event_id + '/remove_organizer',
    data: { _method: 'delete', email: user_email }
  });
}
