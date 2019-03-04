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
    $('#user_for_attendance').on('change', function(){
        const eventId = $('#event_id').val();
        const userId = $('#user_for_attendance').val();

        jQuery.ajax({
            url: `/events/${eventId}/attendances/user_info.js`,
            type: "GET",
            data: `&user_id=${userId}`
        });
    });
}
