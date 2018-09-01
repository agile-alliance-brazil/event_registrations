# frozen_string_literal: true

module ApplicationHelper
  def autotab
    @current_tab ||= 0
    @current_tab += 1
  end

  def link_to_menu_item(tag, name, url, options = {})
    content_tag(tag, class: (current_page?(url) ? 'selected' : '')) do
      link_to name, url, options
    end
  end

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
