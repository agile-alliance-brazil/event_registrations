# encoding: UTF-8
require 'spec_helper'

describe EmailNotifications do
  before do
    ActionMailer::Base.deliveries = []
    @old_locale = I18n.locale
    I18n.locale = :en
    @event = Event.current || FactoryGirl.create(:event)
  end

  after do
    ActionMailer::Base.deliveries.clear
    I18n.locale = @old_locale
  end
  
  context "registration pending" do
    before(:each) do
      @attendance = FactoryGirl.create(:attendance, :event => @event, :registration_date => Time.zone.local(2013, 05, 1, 12, 0, 0))
    end
    
    it "should be sent to attendee cc'ed to event organizer" do
      mail = EmailNotifications.registration_pending(@attendance).deliver
      ActionMailer::Base.deliveries.size.should == 1
      mail.to.should == [@attendance.user.email]
      mail.cc.should == [AppConfig[:organizer][:email], AppConfig[:organizer][:cced_email]]
      mail.encoded.should =~ /Caro #{@attendance.user.full_name},/
      mail.encoded.should =~ /R\$ 499,00/
      mail.encoded.should =~ /#{AppConfig[:organizer][:email]}/
      mail.subject.should == "[localhost:3000] Pedido de inscrição na #{@event.name} enviado"
    end
    
    it "should be sent to attendee according to country" do
      @attendance.user.country = 'US'
      mail = EmailNotifications.registration_pending(@attendance).deliver
      ActionMailer::Base.deliveries.size.should == 1
      mail.to.should == [@attendance.user.email]
      mail.cc.should == [AppConfig[:organizer][:email], AppConfig[:organizer][:cced_email]]
      mail.encoded.should =~ /Dear #{@attendance.user.full_name},/
      mail.encoded.should =~ /R\$ 499,00/
      mail.encoded.should =~ /#{AppConfig[:organizer][:email]}/
      mail.subject.should == "[localhost:3000] Registration request to #{@event.name} sent"
    end
  end

  context "registration confirmed" do
    before(:each) do
      @attendance = FactoryGirl.create(:attendance, :event => @event, :registration_date => Time.zone.local(2013, 05, 01, 12, 0, 0))
    end
    
    it "should be sent to attendee" do
      mail = EmailNotifications.registration_confirmed(@attendance).deliver
      ActionMailer::Base.deliveries.size.should == 1
      mail.to.should == [@attendance.user.email]
      mail.encoded.should =~ /Caro #{@attendance.user.full_name},/
      mail.encoded.should =~ /R\$ 499,00/
      mail.encoded.should =~ /#{AppConfig[:organizer][:email]}/
      mail.subject.should == "[localhost:3000] Inscrição na #{@event.name} confirmada"
    end
    
    it "should be sent to attendee according to country" do
      @attendance.user.country = 'US'
      mail = EmailNotifications.registration_confirmed(@attendance).deliver
      ActionMailer::Base.deliveries.size.should == 1
      mail.to.should == [@attendance.user.email]
      mail.encoded.should =~ /Dear #{@attendance.user.full_name},/
      mail.encoded.should =~ /R\$ 499,00/
      mail.encoded.should =~ /#{AppConfig[:organizer][:email]}/
      mail.subject.should == "[localhost:3000] Registration confirmed for #{@event.name}"
    end
  end

  context "registration reminder" do
    before(:each) do
      @attendance = FactoryGirl.create(:attendance, :registration_date => Time.zone.local(2013, 05, 1, 12, 0, 0), :event => @event)
    end
    
    it "should be sent to attendee cc'ed to event organizer" do
      mail = EmailNotifications.registration_reminder(@attendance).deliver
      ActionMailer::Base.deliveries.size.should == 1
      mail.to.should == [@attendance.user.email]
      mail.cc.should == [AppConfig[:organizer][:email], AppConfig[:organizer][:cced_email]]
      mail.encoded.should =~ /Caro #{@attendance.user.full_name},/
      mail.encoded.should =~ /#{AppConfig[:organizer][:email]}/
      mail.subject.should == "[localhost:3000] Nova forma de pagamento por Paypal para inscrições na #{@event.name}"
      
    end
    
    it "should be sent to attendee using its default_locale" do
      @attendance.user.default_locale = 'en'
      mail = EmailNotifications.registration_reminder(@attendance).deliver
      ActionMailer::Base.deliveries.size.should == 1
      mail.to.should == [@attendance.user.email]
      mail.cc.should == [AppConfig[:organizer][:email], AppConfig[:organizer][:cced_email]]
      mail.encoded.should =~ /Dear #{@attendance.user.full_name},/
      mail.encoded.should =~ /#{AppConfig[:organizer][:email]}/
      mail.subject.should == "[localhost:3000] New payment option via Paypal for registration for #{@event.name}"
    end
  end
  
end
