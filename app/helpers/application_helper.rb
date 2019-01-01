# frozen_string_literal: true

module ApplicationHelper
  def alert
    render('layouts/alert', message: flash[:alert]) if flash[:alert].present?
  end

  def notice
    render('layouts/notice', message: flash[:notice]) if flash[:notice].present?
  end

  def error
    render('layouts/error', message: flash[:error]) if flash[:error].present?
  end
end
