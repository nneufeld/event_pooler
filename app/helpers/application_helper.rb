module ApplicationHelper
	def is_active?(page_name)
		return "active" if params[:action] == page_name
	end
	
	def is_home?()
		return true if params[:action] == 'index'
	end

  def page_title
    (@content_for_title + " - " if @content_for_title).to_s + 'EventPooler'
  end

  def set_title(title)
    @content_for_title = CGI.unescapeHTML(title).html_safe
  end
end