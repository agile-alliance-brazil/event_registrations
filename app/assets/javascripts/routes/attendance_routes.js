function getAttendanceInfo(eventId, email) {
    jQuery.ajax({
        url: "/events/" + eventId + "/attendances/attendance_past_info" + ".js",
        type: "GET",
        data: '&email=' + email
    });
}
