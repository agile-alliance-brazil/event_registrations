describe UserRepository, type: :repository do
  describe '#search_engine' do
    let!(:user) { FactoryBot.create :user, first_name: 'Foo', last_name: 'bar', email: 'foo@bar.com', roles_mask: 1, updated_at: 1.day.from_now }
    let!(:other_user) { FactoryBot.create :user, first_name: 'Sbbrubles', last_name: 'bar', email: 'sbbrubles@bar.com', roles_mask: 1, updated_at: Time.zone.today }
    let!(:third_user) { FactoryBot.create :user, first_name: 'Foo', last_name: 'xpto', email: 'sbbrubles@bla.com', updated_at: 2.days.from_now, roles_mask: 1 }
    let!(:forth_user) { FactoryBot.create :user, first_name: 'Foo', last_name: 'xpto', email: 'sbbrubles@xpto.com', roles_mask: 3, updated_at: 1.day.ago }

    it { expect(UserRepository.instance.search_engine(1, 'foo')).to eq [third_user, user] }
    it { expect(UserRepository.instance.search_engine(1, 'sbbrubles')).to eq [third_user, other_user] }
    it { expect(UserRepository.instance.search_engine(1, 'xpto')).to eq [third_user] }
    it { expect(UserRepository.instance.search_engine(-1)).to eq [third_user, user, other_user, forth_user] }
    it { expect(UserRepository.instance.search_engine(3)).to eq [forth_user] }
    it { expect(UserRepository.instance.search_engine(3, 'sbbrubles')).to eq [forth_user] }
  end
end
