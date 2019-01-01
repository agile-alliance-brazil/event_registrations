function bindClickToAttendanceSearch() {
    $('#search-attendance-btn').on('click', function(){
        const eventId = $('#event_id').val();
        const email = $('#attendance_email').val();

        if (email !== null && email !== '') {
            getAttendanceInfo(eventId, email);
        }
    });
}

function bindClickToLoadUser() {
    $('#load-current-user-btn').on('click', function(){
        $('#attendance_email').val($('#user_email').val());
        $('#attendance_cpf').val($('#user_cpf').val());
        $('#attendance_first_name').val($('#user_first_name').val());
        $('#attendance_last_name').val($('#user_last_name').val());
        $('#attendance_badge_name').val($('#user_badge_name').val());
        $('#attendance_gender').val($('#user_gender').val());
        $('#attendance_country').val($('#user_country').val());
        $('#attendance_state').val($('#user_state').val());
        $('#attendance_city').val($('#user_city').val());
        $('#attendance_phone').val($('#user_phone').val());
        $('#attendance_organization').val($('#user_organization').val());
    });
}
