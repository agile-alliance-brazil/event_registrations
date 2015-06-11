describe AgileAllianceService do
  before { WebMock.enable! }
  after { WebMock.disable! }

  describe '.check_member' do
    context 'when the user is a member' do
      before { stub_request(:post, 'http://cf.agilealliance.org/api/').to_return(:status => 200, :body => '<?xml version=\"1.0\" encoding=\"UTF-8\"?><data><result>1</result></data>', :headers => {}) }
      it { expect(AgileAllianceService.check_member('bla')).to be_truthy }
    end

    context 'when the user is not a member' do
      before { stub_request(:post, 'http://cf.agilealliance.org/api/').to_return(:status => 200, :body => '<?xml version=\"1.0\" encoding=\"UTF-8\"?><data><result>0</result></data>', :headers => {}) }
      it { expect(AgileAllianceService.check_member('bla')).to be_falsey }
    end
  end
end
