# encoding: UTF-8
class AttendanceStatusesController < InheritedResources::Base
  defaults :resource_class => Attendance, :instance_name => "attendance"

  skip_before_filter :authenticate_user!, only: :callback
  skip_before_filter :authorize_action, only: :callback
  protect_from_forgery :except => [:callback]

  actions :show

  def callback
    redirect_to attendance_status_url(params[:id])
  end
  
  private
  def resource
    @attendance ||= end_of_association_chain.find(params[:id])
  end
end