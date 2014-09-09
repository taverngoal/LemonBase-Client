require 'grape'
class MountApi < Grape::API
  format :json
  get 'add' do

  end

  get 'show' do

    User.all
  end

  get 'index' do
    
  end
end