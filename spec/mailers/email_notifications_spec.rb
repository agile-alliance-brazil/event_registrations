# encoding: UTF-8
require 'spec_helper'

describe EmailNotifications, type: :mailer do
  let(:event) { FactoryGirl.create :event }
  before { ActionMailer::Base.deliveries = [] }
  after { ActionMailer::Base.deliveries.clear }

  context 'registration pending' do
    let(:attendance) { FactoryGirl.create(:attendance, event: event) }

    it "sends to attendee cc'ed to event organizer" do
      mail = EmailNotifications.registration_pending(attendance).deliver_now
      expect(ActionMailer::Base.deliveries.size).to eq 1
      expect(mail.to).to eq [attendance.email]
      expect(mail.cc).to eq([APP_CONFIG[:organizer][:email], APP_CONFIG[:organizer][:cced_email]])
      expect(mail.encoded).to match(/Oi #{attendance.full_name},/)
      expect(mail.encoded).to match(/R\$ #{attendance.registration_value}/)
      expect(mail.encoded).to match(/#{APP_CONFIG[:organizer][:contact_email]}/)
      expect(mail.subject).to eq("[#{APP_CONFIG[:host]}] Pedido de inscrição na #{event.name} enviado")
    end

    it 'sends to attendee according to country' do
      attendance.country = 'US'
      mail = EmailNotifications.registration_pending(attendance).deliver_now
      expect(ActionMailer::Base.deliveries.size).to eq 1
      expect(mail.to).to eq [attendance.email]
      expect(mail.cc).to eq([APP_CONFIG[:organizer][:email], APP_CONFIG[:organizer][:cced_email]])
      expect(mail.encoded).to match(/Dear #{attendance.full_name},/)
      expect(mail.encoded).to match(/R\$ #{attendance.registration_value}/)
      expect(mail.encoded).to match(/#{APP_CONFIG[:organizer][:contact_email]}/)
      expect(mail.subject).to eq("[#{APP_CONFIG[:host]}] Registration request to #{event.name} sent")
    end
  end

  context 'registration confirmed' do
    let(:attendance) { FactoryGirl.create(:attendance, event: event, registration_date: Time.zone.local(2013, 05, 01, 12, 0, 0)) }

    context 'when the attendance is brazilian' do
      context 'and event start date before end date' do
        it 'sends the confirmation' do
          mail = EmailNotifications.registration_confirmed(attendance).deliver_now
          expect(ActionMailer::Base.deliveries.size).to eq 1
          expect(mail.to).to eq [attendance.email]
          expect(mail.encoded).to match(/Oi #{attendance.full_name},/)
          expect(mail.encoded).to match(/Quando: #{ I18n.l(attendance.event.start_date.to_date) } #{ I18n.t('title.until')} #{I18n.l(attendance.event.end_date.to_date)}/)
          expect(mail.encoded).to match(/#{APP_CONFIG[:organizer][:contact_email]}/)
          expect(mail.subject).to eq("[#{APP_CONFIG[:host]}] Inscrição na #{event.name} confirmada")
        end
      end

      context 'and with start date equals end date' do
        let(:today_event) { FactoryGirl.create(:event, start_date: Time.zone.today, end_date: Time.zone.today) }
        let(:today_attendance) { FactoryGirl.create(:attendance, event: today_event) }
        it 'show the start date only' do
          mail = EmailNotifications.registration_confirmed(today_attendance).deliver_now
          expect(mail.encoded).to match(/Quando: #{ I18n.l(today_attendance.event.start_date.to_date) }/)
        end
      end
    end

    context 'when the attendance is from other coutry' do
      context 'and event start date before end date' do
        it 'sends the confirmation in english' do
          attendance.country = 'US'
          mail = EmailNotifications.registration_confirmed(attendance).deliver_now
          expect(ActionMailer::Base.deliveries.size).to eq(1)
          expect(mail.to).to eq([attendance.email])
          expect(mail.encoded).to match(/Dear #{attendance.full_name},/)
          expect(mail.encoded).to match(/When: #{ I18n.l(attendance.event.start_date.to_date) } #{ I18n.t('title.until')} #{I18n.l(attendance.event.end_date.to_date)}/)
          expect(mail.encoded).to match(/#{APP_CONFIG[:organizer][:contact_email]}/)
          expect(mail.subject).to eq("[#{APP_CONFIG[:host]}] Registration confirmed for #{event.name}")
        end
      end
      context 'and with start date equals end date' do
        let(:today_event) { FactoryGirl.create(:event, start_date: Time.zone.today, end_date: Time.zone.today) }
        let(:today_attendance) { FactoryGirl.create(:attendance, event: today_event) }
        it 'show the start date only' do
          today_attendance.country = 'US'
          mail = EmailNotifications.registration_confirmed(today_attendance).deliver_now
          expect(mail.encoded).to match(/When: #{ I18n.l(today_attendance.event.start_date.to_date) }/)
        end
      end
    end
  end

  context 'when cancelling registration' do
    let(:event) { FactoryGirl.create :event }
    let(:attendance) { FactoryGirl.create :attendance, event: event }

    it 'sends to pending attendee' do
      mail = EmailNotifications.cancelling_registration(attendance).deliver_now
      expect(ActionMailer::Base.deliveries.size).to eq 1
      expect(mail.to).to eq([attendance.email])
      expect(mail.encoded).to match(/Oi #{attendance.full_name},/)
      expect(mail.encoded).to match(/#{APP_CONFIG[:organizer][:contact_email]}/)
      expect(mail.subject).to eq("[#{APP_CONFIG[:host]}] Aviso de cancelamento da inscrição #{attendance.id} na #{event.name}")
    end

    it 'sends to attendee according to country' do
      attendance.country = 'US'
      mail = EmailNotifications.cancelling_registration(attendance).deliver_now
      expect(ActionMailer::Base.deliveries.size).to eq 1
      expect(mail.to).to eq([attendance.email])
      expect(mail.encoded).to match(/Dear #{attendance.full_name},/)
      expect(mail.encoded).to match(/#{APP_CONFIG[:organizer][:contact_email]}/)
      expect(mail.subject).to eq("[#{APP_CONFIG[:host]}] Notice about registration #{attendance.id} cancelation for #{event.name}")
    end
  end

  context 'when warning attendance about cancelation' do
    let(:event) { FactoryGirl.create :event }
    let(:attendance) { FactoryGirl.create :attendance, event: event }

    it 'should be sent to pending attendee' do
      mail = EmailNotifications.cancelling_registration_warning(attendance).deliver_now
      expect(ActionMailer::Base.deliveries.size).to eq 1
      expect(mail.to).to eq([attendance.email])
      expect(mail.encoded).to match(/Oi #{attendance.full_name},/)
      expect(mail.encoded).to match(/#{APP_CONFIG[:organizer][:contact_email]}/)
      expect(mail.subject).to eq("[#{APP_CONFIG[:host]}] Lembrete de pagamento da inscrição #{attendance.id} na #{event.name}")
    end

    it 'sends to attendee according to country' do
      attendance.country = 'US'
      mail = EmailNotifications.cancelling_registration_warning(attendance).deliver_now
      expect(ActionMailer::Base.deliveries.size).to eq 1
      expect(mail.to).to eq([attendance.email])
      expect(mail.encoded).to match(/Dear #{attendance.full_name},/)
      expect(mail.encoded).to match(/#{APP_CONFIG[:organizer][:contact_email]}/)
      expect(mail.subject).to eq("[#{APP_CONFIG[:host]}] Payment reminder about registration #{attendance.id} for #{event.name}")
    end
  end
end
