module ApplicationHelper
	def is_active?(page_name)
		return "active" if params[:action] == page_name
	end
	
	def is_home?()
		return true if params[:action] == 'index'
	end
end