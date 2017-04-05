class AttendanceExportService
  def self.to_csv(attendance_list = Attendance.all)
    CSV.generate do |csv|
      csv << %i[id first_name last_name organization email payment_type group_name city state value]
      attendance_list.each do |attendance|
        csv << [attendance.id,
                attendance.first_name,
                attendance.last_name,
                attendance.organization,
                attendance.email,
                attendance.payment_type,
                attendance.group_name,
                attendance.city,
                attendance.state,
                attendance.registration_value]
      end
    end
  end
end
