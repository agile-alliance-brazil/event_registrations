# frozen_string_literal: true

class RegistrationGroupsController < AuthenticatedController
  before_action :assign_event
  before_action :assign_group, except: %i[index create]

  def index
    @groups = @event.registration_groups
    @group = RegistrationGroup.new
  end

  def show
    @attendance_list = @group.attendances.active.order(created_at: :desc)
  end

  def destroy
    return redirect_to event_registration_groups_path(@event), notice: t('registration_group.destroy.success') if @group.destroy

    redirect_to(event_registration_groups_path(@event), flash: { error: @group.errors.full_messages.join(',') })
  end

  def create
    @group = RegistrationGroup.new(group_params.merge(event: @event, leader: current_user))
    if @group.save
      redirect_to event_registration_groups_path(@event)
    else
      render :index
    end
  end

  def update
    return redirect_to @event if @group.update(group_params)

    render :edit
  end

  private

  def group_params
    params.require(:registration_group).permit(:name, :discount, :minimum_size, :amount, :automatic_approval, :paid_in_advance, :capacity)
  end

  def assign_event
    @event = Event.find(params[:event_id])
  end

  def assign_group
    @group = @event.registration_groups.find(params[:id])
  end

  def resource_class
    RegistrationGroup
  end
end
