class MainController < ActionController::Base
  def index
    @sharables = Sharable.all
    @types = GroupType.all
  end
end