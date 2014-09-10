require 'rest-client'
class LemonApiBase
  self.Access_Key ='123'
  self.Secret_Key ='321'

  def initialize host
    @client = RestClient.new
  end

  def post params

  end
end