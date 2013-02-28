# encoding: UTF-8
class AttendanceStatusesController < InheritedResources::Base
  defaults :resource_class => Attendance, :instance_name => "attendance"

  actions :show

  def update
  	Rails.logger.info "Received update from BCash with #{params.inspect}"
  	redirect_to attendance_status_path(params[:id])
  end
  
  private
  def resource
    @attendance ||= end_of_association_chain.find(params[:id])
  end
end