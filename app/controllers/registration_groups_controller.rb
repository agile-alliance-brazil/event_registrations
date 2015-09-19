# encoding: UTF-8

class RegistrationGroupsController < ApplicationController
  before_action :find_event
  before_action :find_group, except: [:index, :create]

  def index
    @groups = @event.registration_groups
    @new_group = RegistrationGroup.new
  end

  def show
    @invoice = @group.invoices.last
    @attendance_list = @group.attendances.active.order(created_at: :desc)
  end

  def destroy
    @group.destroy
    redirect_to event_registration_groups_path(@event), notice: t('registration_group.destroy.success')
  end

  def create
    new_group = RegistrationGroup.new(group_params)
    new_group.event = @event
    new_group.leader = current_user
    new_group.save!
    create_invoice(new_group)
    redirect_to event_registration_groups_path(@event)
  end

  def renew_invoice
    @group.update_invoice
    redirect_to event_registration_group_path(@event, @group)
  end

  private

  def group_params
    params.require(:registration_group).permit(:name, :discount, :minimum_size, :amount)
  end

  def find_event
    @event = Event.find params[:event_id]
  rescue ActiveRecord::RecordNotFound
    redirect_to events_path, alert: t('event.not_found')
  end

  def find_group
    @group = RegistrationGroup.find_by(id: params[:id])
  end

  def create_invoice(group)
    Invoice.from_registration_group(group, Invoice::GATEWAY)
  end
end
