# encoding: UTF-8
require 'spec_helper'

describe EmailNotifications do
  before do
    ActionMailer::Base.deliveries = []
    @old_locale = I18n.locale
    I18n.locale = :en
    @event = Event.last || FactoryGirl.build(:event)
    Attendance.any_instance.stubs(:registration_fee).returns(499)
  end

  after do
    ActionMailer::Base.deliveries.clear
    I18n.locale = @old_locale
  end
  
  context "registration pending" do
    before(:each) do
      @attendance = FactoryGirl.build(:attendance, event: @event)
      @attendance.id = 435
    end
    
    it "should be sent to attendee cc'ed to event organizer" do
      mail = EmailNotifications.registration_pending(@attendance).deliver
      ActionMailer::Base.deliveries.size.should == 1
      mail.to.should == [@attendance.email]
      mail.cc.should == [AppConfig[:organizer][:email], AppConfig[:organizer][:cced_email]]
      mail.encoded.should =~ /Caro #{@attendance.full_name},/
      mail.encoded.should =~ /R\$ 499,00/
      mail.encoded.should =~ /#{AppConfig[:organizer][:contact_email]}/
      mail.subject.should == "[localhost:3000] Pedido de inscrição na #{@event.name} enviado"
    end
    
    it "should be sent to attendee according to country" do
      @attendance.country = 'US'
      mail = EmailNotifications.registration_pending(@attendance).deliver
      ActionMailer::Base.deliveries.size.should == 1
      mail.to.should == [@attendance.email]
      mail.cc.should == [AppConfig[:organizer][:email], AppConfig[:organizer][:cced_email]]
      mail.encoded.should =~ /Dear #{@attendance.full_name},/
      mail.encoded.should =~ /R\$ 499,00/
      mail.encoded.should =~ /#{AppConfig[:organizer][:contact_email]}/
      mail.subject.should == "[localhost:3000] Registration request to #{@event.name} sent"
    end
  end

  context "registration confirmed" do
    before(:each) do
      @attendance = FactoryGirl.build(:attendance, :event => @event, :registration_date => Time.zone.local(2013, 05, 01, 12, 0, 0))
      @event.id = 1
    end
    
    it "should be sent to attendee" do
      mail = EmailNotifications.registration_confirmed(@attendance).deliver
      ActionMailer::Base.deliveries.size.should == 1
      mail.to.should == [@attendance.email]
      mail.encoded.should =~ /Caro #{@attendance.full_name},/
      mail.encoded.should =~ /\n\s*1.([^\n]+\n)+\s*2./
      mail.encoded.should =~ /#{AppConfig[:organizer][:contact_email]}/
      mail.subject.should == "[localhost:3000] Inscrição na #{@event.name} confirmada"
    end
    
    it "should be sent to attendee according to country" do
      @attendance.country = 'US'
      mail = EmailNotifications.registration_confirmed(@attendance).deliver
      ActionMailer::Base.deliveries.size.should == 1
      mail.to.should == [@attendance.email]
      mail.encoded.should =~ /Dear #{@attendance.full_name},/
      mail.encoded.should =~ /\n\s*1.([^\n]+\n)+\s*2./
      mail.encoded.should =~ /#{AppConfig[:organizer][:contact_email]}/
      mail.subject.should == "[localhost:3000] Registration confirmed for #{@event.name}"
    end

    it "should be sent according to event id" do
      @event.id = 4
      mail = EmailNotifications.registration_confirmed(@attendance).deliver
      ActionMailer::Base.deliveries.size.should == 1
      mail.to.should == [@attendance.email]
      mail.encoded.should =~ /Naoum Express/
    end
  end

  context "cancelling registration" do
    before(:each) do
      @attendance = FactoryGirl.build(:attendance, :event => @event, :registration_date => Time.zone.local(2013, 05, 01, 12, 0, 0))
    end
    
    it "should be sent to pending attendee" do
      mail = EmailNotifications.cancelling_registration(@attendance).deliver
      ActionMailer::Base.deliveries.size.should == 1
      mail.to.should == [@attendance.email]
      mail.encoded.should =~ /Caro #{@attendance.full_name},/
      mail.encoded.should =~ /#{AppConfig[:organizer][:contact_email]}/
      mail.subject.should == "[localhost:3000] Aviso de cancelamento da inscrição #{@attendance.id} na #{@event.name}"
    end
    
    it "should be sent to attendee according to country" do
      @attendance.country = 'US'
      mail = EmailNotifications.cancelling_registration(@attendance).deliver
      ActionMailer::Base.deliveries.size.should == 1
      mail.to.should == [@attendance.email]
      mail.encoded.should =~ /Dear #{@attendance.full_name},/
      mail.encoded.should =~ /#{AppConfig[:organizer][:contact_email]}/
      mail.subject.should == "[localhost:3000] Notice about registration #{@attendance.id} cancelation for #{@event.name}"
    end
  end

  context "cancel registration warning" do
    before(:each) do
      @attendance = FactoryGirl.build(:attendance, :event => @event, :registration_date => Time.zone.local(2013, 05, 01, 12, 0, 0))
    end
    
    it "should be sent to pending attendee" do
      mail = EmailNotifications.cancelling_registration_warning(@attendance).deliver
      ActionMailer::Base.deliveries.size.should == 1
      mail.to.should == [@attendance.email]
      mail.encoded.should =~ /Caro #{@attendance.full_name},/
      mail.encoded.should =~ /#{AppConfig[:organizer][:contact_email]}/
      mail.subject.should == "[localhost:3000] Lembrete de pagamento da inscrição #{@attendance.id} na #{@event.name}"
    end
    
    it "should be sent to attendee according to country" do
      @attendance.country = 'US'
      mail = EmailNotifications.cancelling_registration_warning(@attendance).deliver
      ActionMailer::Base.deliveries.size.should == 1
      mail.to.should == [@attendance.email]
      mail.encoded.should =~ /Dear #{@attendance.full_name},/
      mail.encoded.should =~ /#{AppConfig[:organizer][:contact_email]}/
      mail.subject.should == "[localhost:3000] Payment reminder about registration #{@attendance.id} for #{@event.name}"
    end
  end
end
