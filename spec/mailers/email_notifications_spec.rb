# encoding: UTF-8
# encoding: utf-8
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
      @attendee = FactoryGirl.create(:attendee, :event => @event, :registration_date => Time.zone.local(2011, 04, 25, 12, 0, 0))
    end
    
    it "should be sent to attendee cc'ed to event organizer" do
      mail = EmailNotifications.registration_pending(@attendee).deliver
      ActionMailer::Base.deliveries.size.should == 1
      mail.to.should == [@attendee.email]
      mail.cc.should == [AppConfig[:organizer][:email], AppConfig[:organizer][:cced_email]]
      mail.encoded.should =~ /Caro #{@attendee.full_name},/
      # mail.encoded.should =~ /#{I18n.l(Date.today + 5)},/
      mail.encoded.should =~ /R\$ 165,00/
      # mail.encoded.should =~ /http:\/\/www\.agilebrazil\.com\.br\/2011\/pt\/inscricoes\.php/
      mail.encoded.should =~ /#{AppConfig[:organizer][:email]}/
      mail.subject.should == "[localhost:3000] Pedido de inscrição na #{@event.name} enviado"
    end
    
    it "should be sent to attendee according to country" do
      @attendee.country = 'US'
      mail = EmailNotifications.registration_pending(@attendee).deliver
      ActionMailer::Base.deliveries.size.should == 1
      mail.to.should == [@attendee.email]
      mail.cc.should == [AppConfig[:organizer][:email], AppConfig[:organizer][:cced_email]]
      mail.encoded.should =~ /Dear #{@attendee.full_name},/
      mail.encoded.should =~ /R\$ 165,00/
      # mail.encoded.should =~ /#{I18n.l(Date.today + 5)},/
      mail.encoded.should =~ /#{AppConfig[:organizer][:email]}/
      # mail.encoded.should =~ /http:\/\/www\.agilebrazil\.com\.br\/2011\/en\/inscricoes\.php/
      mail.subject.should == "[localhost:3000] Registration request to #{@event.name} sent"
    end
  end

  context "registration confirmed" do
    before(:each) do
      @attendee = FactoryGirl.create(:attendee, :event => @event, :registration_date => Time.zone.local(2011, 04, 25, 12, 0, 0))
    end
    
    it "should be sent to attendee" do
      mail = EmailNotifications.registration_confirmed(@attendee).deliver
      ActionMailer::Base.deliveries.size.should == 1
      mail.to.should == [@attendee.email]
      mail.cc.should == []
      mail.encoded.should =~ /Caro #{@attendee.full_name},/
      mail.encoded.should =~ /R\$ 165,00/
      mail.encoded.should =~ /#{AppConfig[:organizer][:email]}/
      mail.subject.should == "[localhost:3000] Inscrição na #{@event.name} confirmada"
    end

    it "should cc group contact if available" do
      group = FactoryGirl.create(:registration_group)
      @attendee.registration_group = group
      
      mail = EmailNotifications.registration_confirmed(@attendee).deliver
      mail.to.should == [@attendee.email]
      mail.cc.should == [group.contact_email]
    end
    
    it "should be sent to attendee according to country" do
      @attendee.country = 'US'
      mail = EmailNotifications.registration_confirmed(@attendee).deliver
      ActionMailer::Base.deliveries.size.should == 1
      mail.to.should == [@attendee.email]
      mail.cc.should == []
      mail.encoded.should =~ /Dear #{@attendee.full_name},/
      mail.encoded.should =~ /R\$ 165,00/
      mail.encoded.should =~ /#{AppConfig[:organizer][:email]}/
      mail.subject.should == "[localhost:3000] Registration confirmed for #{@event.name}"
    end
  end

  context "registration group attendee" do
    before(:each) do
      @registration_group = FactoryGirl.create(:registration_group)
      @attendee = FactoryGirl.create(:attendee, :event => @event,
        :registration_date => Time.zone.local(2011, 04, 25, 12, 0, 0),
        :registration_type => RegistrationType.find_by_title('registration_type.group'),
        :registration_group => @registration_group
      )
    end
    
    it "should be sent to attendee cc'ed to group organizer" do
      mail = EmailNotifications.registration_group_attendee(@attendee, @registration_group).deliver
      ActionMailer::Base.deliveries.size.should == 1
      mail.to.should == [@attendee.email]
      mail.cc.should == [@registration_group.contact_email]
      mail.encoded.should =~ /Caro #{@attendee.full_name},/
      mail.encoded.should =~ /#{AppConfig[:organizer][:email]}/
      mail.subject.should == "[localhost:3000] Pedido de inscrição em empresa na #{@event.name} enviado"
    end
  
    it "should be sent to attendee according to country" do
      @attendee.country = 'US'
      mail = EmailNotifications.registration_group_attendee(@attendee, @registration_group).deliver
      ActionMailer::Base.deliveries.size.should == 1
      mail.to.should == [@attendee.email]
      mail.cc.should == [@registration_group.contact_email]
      mail.encoded.should =~ /Dear #{@attendee.full_name},/
      mail.encoded.should =~ /#{AppConfig[:organizer][:email]}/
      mail.subject.should == "[localhost:3000] Company registration request to #{@event.name} sent"
    end
  end
    
  context "registration group pending" do
    before(:each) do
      @registration_group = FactoryGirl.create(:registration_group)
      @attendee = FactoryGirl.create(:attendee, :event => @event,
        :registration_date => Time.zone.local(2011, 04, 25, 12, 0, 0),
        :registration_type => RegistrationType.find_by_title('registration_type.group'),
        :registration_group => @registration_group
      )
    end

    it "should be sent to group organizer cc'ed to event organizer" do
      mail = EmailNotifications.registration_group_pending(@registration_group).deliver
      ActionMailer::Base.deliveries.size.should == 1
      mail.to.should == [@registration_group.contact_email]
      mail.cc.should == [AppConfig[:organizer][:email], AppConfig[:organizer][:cced_email]]
      mail.encoded.should =~ /#{@registration_group.contact_name},/
      mail.encoded.should =~ /R\$ 135,00/
      mail.encoded.should =~ /#{AppConfig[:organizer][:email]}/
      mail.subject.should == "[localhost:3000] Pedido de inscrição em empresa na #{@event.name} enviado"
    end
  
    it "should be sent to group organizer according to country" do
      @registration_group.country = 'US'
      mail = EmailNotifications.registration_group_pending(@registration_group).deliver
      ActionMailer::Base.deliveries.size.should == 1
      mail.to.should == [@registration_group.contact_email]
      mail.cc.should == [AppConfig[:organizer][:email], AppConfig[:organizer][:cced_email]]
      mail.encoded.should =~ /Dear #{@registration_group.contact_name},/
      mail.encoded.should =~ /R\$ 135,00/
      mail.encoded.should =~ /#{AppConfig[:organizer][:email]}/
      mail.subject.should == "[localhost:3000] Company registration request to #{@event.name} sent"
    end
  end
  
  context "registration group confirmed" do
    before(:each) do
      @registration_group = FactoryGirl.create(:registration_group)
    end
    
    it "should be sent to group contact" do
      mail = EmailNotifications.registration_group_confirmed(@registration_group).deliver
      ActionMailer::Base.deliveries.size.should == 1
      mail.to.should == [@registration_group.contact_email]
      mail.cc.should == [AppConfig[:organizer][:email], AppConfig[:organizer][:cced_email]]
      mail.encoded.should =~ /#{AppConfig[:organizer][:email]}/
      mail.subject.should == "[localhost:3000] Inscrição na #{@event.name} confirmada"
    end
    
    it "should be sent to group contact according to country" do
      @registration_group.country = 'US'
      mail = EmailNotifications.registration_group_confirmed(@registration_group).deliver
      ActionMailer::Base.deliveries.size.should == 1
      mail.to.should == [@registration_group.contact_email]
      mail.cc.should == [AppConfig[:organizer][:email], AppConfig[:organizer][:cced_email]]
      mail.encoded.should =~ /Dear #{@registration_group.contact_name},/
      mail.encoded.should =~ /#{AppConfig[:organizer][:email]}/
      mail.subject.should == "[localhost:3000] Registration confirmed for #{@event.name}"
    end
  end

  context "registration reminder" do
    before(:each) do
      @attendee = FactoryGirl.create(:attendee, :registration_date => Time.zone.local(2011, 04, 25, 12, 0, 0), :event => @event)
    end
    
    it "should be sent to attendee cc'ed to event organizer" do
      mail = EmailNotifications.registration_reminder(@attendee).deliver
      ActionMailer::Base.deliveries.size.should == 1
      mail.to.should == [@attendee.email]
      mail.cc.should == [AppConfig[:organizer][:email], AppConfig[:organizer][:cced_email]]
      mail.encoded.should =~ /Caro #{@attendee.full_name},/
      mail.encoded.should =~ /#{AppConfig[:organizer][:email]}/
      mail.subject.should == "[localhost:3000] Nova forma de pagamento por Paypal para inscrições na #{@event.name}"
      
    end
    
    it "should be sent to attendee using its default_locale" do
      @attendee.default_locale = 'en'
      mail = EmailNotifications.registration_reminder(@attendee).deliver
      ActionMailer::Base.deliveries.size.should == 1
      mail.to.should == [@attendee.email]
      mail.cc.should == [AppConfig[:organizer][:email], AppConfig[:organizer][:cced_email]]
      mail.encoded.should =~ /Dear #{@attendee.full_name},/
      mail.encoded.should =~ /#{AppConfig[:organizer][:email]}/
      mail.subject.should == "[localhost:3000] New payment option via Paypal for registration for #{@event.name}"
    end
  end
  
end
