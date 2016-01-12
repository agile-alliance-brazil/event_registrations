# encoding: UTF-8
# == Schema Information
#
# Table name: registration_groups
#
#  id           :integer          not null, primary key
#  event_id     :integer
#  name         :string(255)
#  capacity     :integer
#  discount     :integer
#  token        :string(255)
#  created_at   :datetime
#  updated_at   :datetime
#  leader_id    :integer
#  invoice_id   :integer
#  minimum_size :integer
#  amount       :decimal(10, )
#
# Indexes
#
#  fk_rails_9544e3707e  (invoice_id)
#

class RegistrationGroupsController < ApplicationController
  before_action :find_event
  before_action :find_group, except: %i(index create)

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
