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
end
