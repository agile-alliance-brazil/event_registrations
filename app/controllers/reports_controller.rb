class ReportsController < ApplicationController
  skip_before_action :authorize_action

  def attendance_organization_size
    return not_found unless can?(:read, ReportsController)
    @attendance_organization_size_data = event.attendances.active.group(:organization_size).count.to_a.map { |x| x.map { |x_part| x_part || I18n.t('report.attendance_organization_size.unknown') } }
  end
end
