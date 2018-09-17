function bindBlurToAttendanceEmail() {
    $('#attendance_email').on('blur', function(event){
        const eventId = $('#event_id').val();
        const email = $(event.target).val();

        if (email !== null && email !== '') {
            getAttendanceInfo(eventId, email);
        }
    });
}
