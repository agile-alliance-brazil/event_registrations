# frozen_string_literal: true

describe UserRepository, type: :repository do
  describe '#search_engine' do
    let!(:user) { FactoryBot.create :user, first_name: 'Foo', last_name: 'bar', email: 'foo@bar.com', role: :user, updated_at: 1.day.from_now }
    let!(:other_user) { FactoryBot.create :user, first_name: 'Sbbrubles', last_name: 'bar', email: 'sbbrubles@bar.com', role: :user, updated_at: Time.zone.today }
    let!(:third_user) { FactoryBot.create :user, first_name: 'Foo', last_name: 'xpto', email: 'sbbrubles@bla.com', updated_at: 2.days.from_now, role: :user }
    let!(:forth_user) { FactoryBot.create :user, first_name: 'Foo', last_name: 'xpto', email: 'sbbrubles@xpto.com', role: :admin, updated_at: 1.day.ago }

    it { expect(UserRepository.instance.search_engine(:user, 'foo')).to eq [third_user, user] }
    it { expect(UserRepository.instance.search_engine(:user, 'sbbrubles')).to eq [third_user, other_user] }
    it { expect(UserRepository.instance.search_engine(:user, 'xpto')).to eq [third_user] }
    it { expect(UserRepository.instance.search_engine).to eq [third_user, user, other_user, forth_user] }
    it { expect(UserRepository.instance.search_engine(:admin)).to eq [forth_user] }
    it { expect(UserRepository.instance.search_engine(:admin, 'sbbrubles')).to eq [forth_user] }
    it { expect(UserRepository.instance.search_engine(:admin, 'bar')).to eq [] }
  end
end
