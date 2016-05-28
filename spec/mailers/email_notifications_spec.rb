# encoding: UTF-8

describe EmailNotifications, type: :mailer do
  let(:event) { FactoryGirl.create :event }
  before { ActionMailer::Base.deliveries = [] }
  after { ActionMailer::Base.deliveries.clear }

  describe '#registration_pending' do
    let(:attendance) { FactoryGirl.create(:attendance, event: event) }

    context 'having no organizers in the event' do
      it 'sends to attendee cc the events organizer' do
        mail = EmailNotifications.registration_pending(attendance).deliver_now
        expect(ActionMailer::Base.deliveries.size).to eq 1
        expect(mail.to).to eq [attendance.email]
        expect(mail.cc).to eq [APP_CONFIG[:organizer][:email]]
        expect(mail.encoded).to match(/Oi #{attendance.full_name},/)
        expect(mail.encoded).to match(/R\$ #{attendance.registration_value}/)
        expect(mail.encoded).to match(/#{attendance.event.main_email_contact}/)
        expect(mail.subject).to eq("Pedido de inscrição para #{event.name} enviado")
      end
    end

    context 'having organizers in the event' do
      let(:organizer) { FactoryGirl.create :organizer }
      let(:other_organizer) { FactoryGirl.create :organizer }
      let!(:event) { FactoryGirl.create :event, organizers: [organizer, other_organizer] }

      it 'sends to attendee and cc the events organizer' do
        mail = EmailNotifications.registration_pending(attendance).deliver_now
        expect(ActionMailer::Base.deliveries.size).to eq 1
        expect(mail.to).to eq [attendance.email]
        expect(mail.cc).to eq [organizer.email, other_organizer.email]
      end
    end
  end

  describe '#registration_waiting' do
    let(:attendance) { FactoryGirl.create(:attendance, event: event, status: :waiting) }

    context 'having no organizers in the event' do
      it 'sends to attendee and cc the events organizer' do
        mail = EmailNotifications.registration_waiting(attendance).deliver_now
        expect(ActionMailer::Base.deliveries.size).to eq 1
        expect(mail.to).to eq [attendance.email]
        expect(mail.cc).to eq [APP_CONFIG[:organizer][:email]]
        expect(mail.encoded).to match(/Oi #{attendance.full_name},/)
        expect(mail.encoded).to match(/#{attendance.event.main_email_contact}/)
        expect(mail.subject).to eq("Sua inscrição para #{event.name} está na fila de espera")
      end
    end

    context 'having organizers in the event' do
      let(:organizer) { FactoryGirl.create :organizer }
      let(:other_organizer) { FactoryGirl.create :organizer }
      let!(:event) { FactoryGirl.create :event, organizers: [organizer, other_organizer] }

      it 'sends to attendee cc the events organizer' do
        mail = EmailNotifications.registration_pending(attendance).deliver_now
        expect(ActionMailer::Base.deliveries.size).to eq 1
        expect(mail.to).to eq [attendance.email]
        expect(mail.cc).to eq [organizer.email, other_organizer.email]
      end
    end
  end

  describe '#registration_confirmed' do
    let(:attendance) { FactoryGirl.create(:attendance, event: event, registration_date: Time.zone.local(2013, 05, 01, 12, 0, 0)) }

    context 'when the attendance is brazilian' do
      context 'and event start date before end date' do
        it 'sends the confirmation' do
          mail = EmailNotifications.registration_confirmed(attendance).deliver_now
          expect(ActionMailer::Base.deliveries.size).to eq 1
          expect(mail.to).to eq [attendance.email]
          expect(mail.encoded).to match(/Oi #{attendance.full_name},/)
          expect(mail.encoded).to match(/Quando: #{ I18n.l(attendance.event.start_date.to_date) } #{ I18n.t('title.until')} #{I18n.l(attendance.event.end_date.to_date)}/)
          expect(mail.encoded).to match(/#{attendance.event.main_email_contact}/)
          expect(mail.subject).to eq("Inscrição para #{event.name} confirmada")
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

    context 'having organizers in the event' do
      let(:organizer) { FactoryGirl.create :organizer }
      let(:other_organizer) { FactoryGirl.create :organizer }
      let!(:event) { FactoryGirl.create :event, organizers: [organizer, other_organizer] }

      it 'sends to attendee cc the events organizer' do
        mail = EmailNotifications.registration_confirmed(attendance).deliver_now
        expect(ActionMailer::Base.deliveries.size).to eq 1
        expect(mail.to).to eq [attendance.email]
        expect(mail.cc).to eq [organizer.email, other_organizer.email]
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
          expect(mail.encoded).to match(/#{attendance.event.main_email_contact}/)
          expect(mail.subject).to eq("Registration request to #{event.name} confirmed")
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

  describe '#cancelling_registration' do
    let(:event) { FactoryGirl.create :event }
    let(:attendance) { FactoryGirl.create :attendance, event: event }

    it 'sends to pending attendee' do
      mail = EmailNotifications.cancelling_registration(attendance).deliver_now
      expect(ActionMailer::Base.deliveries.size).to eq 1
      expect(mail.to).to eq([attendance.email])
      expect(mail.encoded).to match(/Oi #{attendance.full_name},/)
      expect(mail.encoded).to match(/#{attendance.event.main_email_contact}/)
      expect(mail.subject).to eq("Aviso de cancelamento da inscrição #{attendance.id} para #{event.name}")
    end

    it 'sends to attendee according to country' do
      attendance.country = 'US'
      mail = EmailNotifications.cancelling_registration(attendance).deliver_now
      expect(ActionMailer::Base.deliveries.size).to eq 1
      expect(mail.to).to eq([attendance.email])
      expect(mail.encoded).to match(/Dear #{attendance.full_name},/)
      expect(mail.encoded).to match(/#{attendance.event.main_email_contact}/)
      expect(mail.subject).to eq("Notice about registration #{attendance.id} cancelation to #{event.name}")
    end

    context 'having organizers in the event' do
      let(:organizer) { FactoryGirl.create :organizer }
      let(:other_organizer) { FactoryGirl.create :organizer }
      let!(:event) { FactoryGirl.create :event, organizers: [organizer, other_organizer] }

      it 'sends to attendee cc the events organizer' do
        mail = EmailNotifications.cancelling_registration(attendance).deliver_now
        expect(ActionMailer::Base.deliveries.size).to eq 1
        expect(mail.to).to eq [attendance.email]
        expect(mail.cc).to eq [organizer.email, other_organizer.email]
      end
    end
  end

  describe '#cancelling_registration_warning' do
    let(:event) { FactoryGirl.create :event }
    let(:attendance) { FactoryGirl.create :attendance, event: event }

    it 'should be sent to pending attendee' do
      mail = EmailNotifications.cancelling_registration_warning(attendance).deliver_now
      expect(ActionMailer::Base.deliveries.size).to eq 1
      expect(mail.to).to eq([attendance.email])
      expect(mail.encoded).to match(/Oi #{attendance.full_name},/)
      expect(mail.encoded).to match(/#{attendance.event.main_email_contact}/)
      expect(mail.subject).to eq("Lembrete de pagamento da inscrição #{attendance.id} para #{event.name}")
    end

    it 'sends to attendee according to country' do
      attendance.country = 'US'
      mail = EmailNotifications.cancelling_registration_warning(attendance).deliver_now
      expect(ActionMailer::Base.deliveries.size).to eq 1
      expect(mail.to).to eq([attendance.email])
      expect(mail.encoded).to match(/Dear #{attendance.full_name},/)
      expect(mail.encoded).to match(/#{attendance.event.main_email_contact}/)
      expect(mail.subject).to eq("Payment reminder about registration #{attendance.id} to #{event.name}")
    end

    context 'having organizers in the event' do
      let(:organizer) { FactoryGirl.create :organizer }
      let(:other_organizer) { FactoryGirl.create :organizer }
      let!(:event) { FactoryGirl.create :event, organizers: [organizer, other_organizer] }

      it 'sends to attendee cc the events organizer' do
        mail = EmailNotifications.cancelling_registration_warning(attendance).deliver_now
        expect(ActionMailer::Base.deliveries.size).to eq 1
        expect(mail.to).to eq [attendance.email]
        expect(mail.cc).to eq [organizer.email, other_organizer.email]
      end
    end

    context 'when event is full' do
      let(:full_event) { FactoryGirl.create :event, attendance_limit: 1 }
      let!(:attendance) { FactoryGirl.create :attendance, event: full_event }

      it 'sends the email warning about the queue' do
        mail = EmailNotifications.cancelling_registration_warning(attendance).deliver_now
        expect(mail.encoded).to match(/fila de espera/)
      end
    end
  end

  describe '#registration_dequeued' do
    let(:attendance) { FactoryGirl.create(:attendance, event: event) }

    context 'having no organizers in the event' do
      it 'sends to attendee cc the events organizer in the config file' do
        mail = EmailNotifications.registration_dequeued(attendance).deliver_now
        expect(ActionMailer::Base.deliveries.size).to eq 1
        expect(mail.to).to eq [attendance.email]
        expect(mail.cc).to eq [APP_CONFIG[:organizer][:email]]
        expect(mail.encoded).to match(/Oi #{attendance.full_name},/)
        expect(mail.encoded).to match(/Nossa fila andou e chegou a sua vez!/)
        expect(mail.encoded).to match(/#{attendance.event.main_email_contact}/)
        expect(mail.subject).to eq("Aeee! Nossa fila andou e a sua inscrição para #{event.name} foi recebida!")
      end
    end

    context 'having organizers in the event' do
      let(:organizer) { FactoryGirl.create :organizer }
      let(:other_organizer) { FactoryGirl.create :organizer }
      let!(:event) { FactoryGirl.create :event, organizers: [organizer, other_organizer] }

      it 'sends to attendee and cc the events organizer' do
        mail = EmailNotifications.registration_dequeued(attendance).deliver_now
        expect(ActionMailer::Base.deliveries.size).to eq 1
        expect(mail.to).to eq [attendance.email]
        expect(mail.cc).to eq [organizer.email, other_organizer.email]
      end
    end
  end

  describe '#welcome_attendance' do
    let(:event) { FactoryGirl.create(:event, start_date: 1.day.from_now) }
    let(:out_event) { FactoryGirl.create(:event, start_date: 2.days.from_now) }
    let(:attendance) { FactoryGirl.create(:attendance, event: event) }
    let(:out_attendance) { FactoryGirl.create(:attendance, event: out_event) }

    context 'having no organizers in the event' do
      it 'sends to attendee cc the events organizer in the config file' do
        mail = EmailNotifications.welcome_attendance(attendance).deliver_now
        expect(ActionMailer::Base.deliveries.size).to eq 1
        expect(mail.to).to eq [attendance.email]
        expect(mail.cc).to eq [APP_CONFIG[:organizer][:email]]
        expect(mail.encoded).to match(/Oi #{attendance.full_name},/)
        expect(mail.encoded).to match(/mais um dia/)
        expect(mail.encoded).to match(/#{attendance.event.main_email_contact}/)
        expect(mail.encoded).to match(/#{attendance.event.start_date.to_date.strftime('%H:%M')}/)
        expect(mail.subject).to eq("Bem vindo ao #{event.name}! É amanhã!")
      end
    end

    context 'having organizers in the event' do
      let(:organizer) { FactoryGirl.create :organizer }
      let(:other_organizer) { FactoryGirl.create :organizer }
      let!(:event) { FactoryGirl.create :event, start_date: 1.day.from_now, organizers: [organizer, other_organizer] }

      it 'sends to attendee and cc the events organizer' do
        mail = EmailNotifications.welcome_attendance(attendance).deliver_now
        expect(ActionMailer::Base.deliveries.size).to eq 1
        expect(mail.to).to eq [attendance.email]
        expect(mail.cc).to eq [organizer.email, other_organizer.email]
      end
    end
  end
end
