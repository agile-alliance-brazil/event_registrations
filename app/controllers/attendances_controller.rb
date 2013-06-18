# encoding: UTF-8
class AttendancesController < InheritedResources::Base
  before_filter :set_event
  skip_before_filter :authenticate_user!, only: :callback
  skip_before_filter :authorize_action, only: :callback
  protect_from_forgery :except => [:callback]

  actions :show, :destroy

  def bcash_callback
    redirect_to attendance_path(attendance)
  end

  def destroy
    attendance.cancel
    
    redirect_to attendance_path(attendance)
  end

  def confirm
    begin
      attendance.confirm
    rescue => ex
      flash[:alert] = t('flash.attendance.mail.fail')
      Rails.logger.error('Airbrake notification failed. Logging error locally only')
      Rails.logger.error(ex.message)
    end

    redirect_to attendance_path(attendance)
  end

  def enable_voting
    if attendance.can_vote?
      authentication = current_user.authentications.where(:provider => :submission_system).first
      result = authentication ? authentication.get_token.post('/api/user/make_voter').parsed : {}

      if result['success']
        flash[:notice] = t('flash.attendance.enable_voting.success', :url => result['vote_url']).html_safe
      else
        flash[:error] = t('flash.attendance.enable_voting.missing_authentication')
      end
    end
    
    redirect_to :back
  end

  def voting_instructions
    @submission_system_authentication = current_user.authentications.find_by_provider('submission_system')
  end
  
  private
  def attendance
    @attendance ||= Attendance.find(params[:id])
  end

  def set_event
    @event = attendance.event
  end
end
