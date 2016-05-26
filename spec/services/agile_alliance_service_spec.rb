RSpec.describe AgileAllianceService do
  before { WebMock.enable! }
  after { WebMock.disable! }

  let(:token) { APP_CONFIG[:agile_alliance][:api_token] }
  let(:headers) { { 'Authorization' => token } }
  let(:host) { "#{APP_CONFIG[:agile_alliance][:api_host]}/check_member/bla" }

  describe '.check_member' do
    context 'when the user is a member' do
      before { WebMock.stub_request(:get, host).with(headers: headers).to_return(body: { member: true }.to_json, headers: {}) }
      it { expect(AgileAllianceService.check_member('bla')).to be_truthy }
    end

    context 'when the user is not a member' do
      before { WebMock.stub_request(:get, host).with(headers: headers).to_return(body: { member: false }.to_json, headers: {}) }
      it { expect(AgileAllianceService.check_member('bla')).to be_falsey }
    end
  end
end
