require 'spec_helper'

describe Transfer, type: :model do
  subject { Transfer.build({}) }
  it { should_not be_persisted }

  before do
    @origin = FactoryGirl.build(:attendance)
    @origin.id = 3
    @origin.stubs(:new_record?).returns(false)
    @origin.status = 'paid'
    @destination = FactoryGirl.build(:attendance)
    @destination.id = 5
    @destination.stubs(:new_record?).returns(false)

    Attendance.stubs(:find).with(3).returns @origin
    Attendance.stubs(:find).with(5).returns @destination

    @origin.stubs(:save).returns(true)
    @destination.stubs(:save).returns(true)

    @transfer = Transfer.build(origin_id: 3, destination_id: 5)
  end

  context 'validations' do
    it 'should not be valid without origin' do
      transfer = Transfer.build(destination_id: 5)
      expect(transfer).not_to be_valid
    end
    it 'should not be valid with pending origin' do
      @origin.status = 'pending'

      expect(@transfer).not_to be_valid
    end
    it 'should not be valid with cancelled origin' do
      @origin.status = 'cancel'

      expect(@transfer).not_to be_valid
    end

    it 'should not be valid without destination' do
      transfer = Transfer.build(origin_id: 3)
      expect(transfer).not_to be_valid
    end
    it 'should not be valid with paid destination' do
      @destination.status = 'paid'

      expect(@transfer).not_to be_valid
    end
    it 'should not be valid with confirmed destination' do
      @destination.status = 'confirmed'

      expect(@transfer).not_to be_valid
    end
    it 'should not be valid with cancelled destination' do
      @destination.status = 'cancelled'

      expect(@transfer).not_to be_valid
    end

    it 'should be valid with paid origin and pending destination' do
      expect(@transfer).to be_valid
    end
    it 'should be valid with confirmed origin and pending destination' do
      @origin.status = 'confirmed'

      expect(@transfer).to be_valid
    end
  end

  context 'saving' do
    it 'should not try to change origin id and timestamps' do
      timestamp = Time.zone.now
      @origin.created_at = timestamp
      @origin.updated_at = timestamp

      @transfer.save

      expect(@origin.id).to eq(3)
      expect(@origin.created_at).to eq(timestamp)
      expect(@origin.updated_at).to eq(timestamp)
    end
    it 'should not change origin registration_date' do
      date = Time.zone.now
      @origin.registration_date = date

      @transfer.save

      expect(@origin.registration_date).to eq(date)
    end
    it 'should not change origin email_sent' do
      @origin.email_sent = true

      @transfer.save

      expect(@origin.email_sent).to be true
    end
    it 'should not change origin status' do
      @transfer.save

      expect(@origin.status).to eq('paid')
    end
    it 'should switch all other attributes with destination' do
      destination_name = @destination.last_name
      destination_email = @destination.email
      destination_badge_name = @destination.badge_name
      destination_twitter_user = @destination.twitter_user

      @transfer.save

      expect(@origin.last_name).to eq(destination_name)
      expect(@origin.email).to eq(destination_email)
      expect(@origin.badge_name).to eq(destination_badge_name)
      expect(@origin.twitter_user).to eq(destination_twitter_user)
    end
  end

  context 'build' do
    it 'should create empty transfer from empty hash' do
      transfer = Transfer.build({})

      expect(transfer.origin).to be_new_record
      expect(transfer.origin.id).to be_nil
      expect(transfer.destination).to be_new_record
      expect(transfer.destination.id).to be_nil
    end
    it 'should create transfer with origin if hash has origin_id' do
      transfer = Transfer.build(origin_id: 3)

      expect(transfer.origin).to eq(@origin)
    end
    it 'should create transfer with destination if hash has destination_id' do
      transfer = Transfer.build(destination_id: 5)

      expect(transfer.destination).to eq(@destination)
    end
  end
end