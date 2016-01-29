describe UserRepository, type: :repository do
  describe '#search_engine' do
    let!(:user) { FactoryGirl.create :user, first_name: 'Foo', last_name: 'bar', email: 'foo@bar.com' }
    let!(:other_user) { FactoryGirl.create :user, first_name: 'Sbbrubles', last_name: 'bar', email: 'sbbrubles@bar.com' }
    let!(:third_user) { FactoryGirl.create :user, first_name: 'Foo', last_name: 'xpto', email: 'sbbrubles@bla.com', updated_at: 2.days.from_now }

    it { expect(UserRepository.instance.search_engine('foo')).to eq [third_user, user] }
    it { expect(UserRepository.instance.search_engine('sbbrubles')).to eq [third_user, other_user] }
    it { expect(UserRepository.instance.search_engine('xpto')).to eq [third_user] }
    it { expect(UserRepository.instance.search_engine).to eq [third_user, user, other_user] }
  end
end
