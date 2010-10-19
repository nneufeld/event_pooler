class MainController < ApplicationController
  def index
    @sharables = Sharable.all
    @types = GroupType.all
  end
end