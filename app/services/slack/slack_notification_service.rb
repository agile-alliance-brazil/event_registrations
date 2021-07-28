# frozen_string_literal: true

module Slack
  class SlackNotificationService
    include Singleton

    include ActionView::Helpers::NumberHelper

    def notify_new_registration(slack_notifier, attendance)
      event = attendance.event

      attendance_message = I18n.t('slack_configurations.notifications.notify_new_registration.attendance',
                                  event_name: attendance.event_name,
                                  registration_date: I18n.l(attendance.registration_date, format: :short))

      group_message = ''

      I18n.t('slack_configurations.notifications.notify_new_registration.group', group_name: attendance.group_name) if attendance.registration_group.present?

      value_message = I18n.t('slack_configurations.notifications.notify_new_registration.registration_value',
                             registration_value: number_to_currency(attendance.registration_value))

      summary_message = I18n.t('slack_configurations.notifications.notify_new_registration.attendances_summary',
                               pending: event.attendances.pending.count,
                               accepted: event.attendances.accepted.count,
                               paid: event.attendances.paid.count,
                               confirmed: event.attendances.confirmed.count)

      slack_notifier.ping("#{attendance_message}\n#{group_message}\n#{value_message}\n#{summary_message}")
    rescue Slack::Notifier::APIError
      Rails.logger.error('Invalid Slack API - It may be caused by an API token problem')
    end
  end
end
