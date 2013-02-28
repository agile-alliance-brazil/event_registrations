# encoding: UTF-8
class AttendanceStatusesController < InheritedResources::Base
  defaults :resource_class => Attendance, :instance_name => "attendance"

  actions :show
  
  private
  def resource
    @attendance ||= end_of_association_chain.find(params[:id])
  end
end