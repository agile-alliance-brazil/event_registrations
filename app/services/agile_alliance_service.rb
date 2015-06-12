module AgileAllianceService
  def self.check_member(email)
    params = "<?xml version='1.0' encoding='UTF-8'?><data><api_key>#{APP_CONFIG[:agile_alliance][:api_token]}</api_key><email>#{email}</email></data>"
    response = Net::HTTP.new('cf.agilealliance.org').post('/api/', params)
    hash = Hash.from_xml(response.body)
    return true if hash['data']['result'] == '1'
    false
  end
end
