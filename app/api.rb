
class Spa::API < Grape::API
  prefix 'api'
  format :json
  include Grape::ActiveRecordExtension

  before do

  end
  mount MountApi
end