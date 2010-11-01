module ApplicationHelper
	def is_active?(page_name)
		return "active" if params[:action] == page_name
	end
end