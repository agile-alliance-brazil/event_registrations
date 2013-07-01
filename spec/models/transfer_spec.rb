require 'spec_helper'

describe Transfer do
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
      transfer.should_not be_valid
    end
    it 'should not be valid with pending origin' do
      @origin.status = 'pending'
      
      @transfer.should_not be_valid
    end
    it 'should not be valid with cancelled origin' do
      @origin.status = 'cancel'
      
      @transfer.should_not be_valid
    end

    it 'should not be valid without destination' do
      transfer = Transfer.build(origin_id: 3)
      transfer.should_not be_valid
    end
    it 'should not be valid with paid destination' do
      @destination.status = 'paid'
      
      @transfer.should_not be_valid
    end
    it 'should not be valid with confirmed destination' do
      @destination.status = 'confirmed'
      
      @transfer.should_not be_valid
    end
    it 'should not be valid with cancelled destination' do
      @destination.status = 'cancelled'
      
      @transfer.should_not be_valid
    end

    it 'should be valid with paid origin and pending destination' do
      @transfer.should be_valid
    end
    it 'should be valid with confirmed origin and pending destination' do
      @origin.status = 'confirmed'

      @transfer.should be_valid
    end
  end

  context 'saving' do
    it 'should not try to change origin id and timestamps' do
      timestamp = Time.zone.now
      @origin.created_at = timestamp
      @origin.updated_at = timestamp

      @transfer.save

      @origin.id.should == 3
      @origin.created_at.should == timestamp
      @origin.updated_at.should == timestamp
    end
    it 'should not change origin registration_date' do
      date = Time.zone.now
      @origin.registration_date = date

      @transfer.save

      @origin.registration_date.should == date
    end
    it 'should not change origin email_sent' do
      @origin.email_sent = true

      @transfer.save

      @origin.email_sent.should be_true
    end
    it 'should not change origin status' do
      @transfer.save

      @origin.status.should == 'paid'
    end
    it 'should switch all other attributes with destination' do
      destination_name = @destination.last_name
      destination_email = @destination.email
      destination_badge_name = @destination.badge_name
      destination_twitter_user = @destination.twitter_user

      @transfer.save

      @origin.last_name.should == destination_name
      @origin.email.should == destination_email
      @origin.badge_name.should == destination_badge_name
      @origin.twitter_user.should == destination_twitter_user
    end
  end

  context 'build' do
    it 'should create empty transfer from empty hash' do
      transfer = Transfer.build({})

      transfer.origin.should be_new_record
      transfer.origin.id.should be_nil
      transfer.destination.should be_new_record
      transfer.destination.id.should be_nil
    end
    it 'should create transfer with origin if hash has origin_id' do
      transfer = Transfer.build(origin_id: 3)

      transfer.origin.should == @origin
    end
    it 'should create transfer with destination if hash has destination_id' do
      transfer = Transfer.build(destination_id: 5)

      transfer.destination.should == @destination
    end
  end
end