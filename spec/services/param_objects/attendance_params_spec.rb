RSpec.describe AttendanceParams, type: :param_object do
  let(:user) { FactoryBot.create :user }
  let(:event) { FactoryBot.create :event }

  describe '#new_attributes' do
    it 'returns all parameters for attendance' do
      valid_attendance = { attendance:
                             {
                               event_id: event.id,
                               user_id: user.id,
                               first_name: user.first_name,
                               last_name: user.last_name,
                               email: user.email,
                               organization: user.organization,
                               phone: user.phone,
                               country: user.country,
                               state: 'sc',
                               city: user.city,
                               badge_name: user.badge_name,
                               cpf: user.cpf.numero,
                               gender: user.gender
                             } }
      now = Time.zone.now
      Time.stubs(:now).returns(now)
      params = ActionController::Parameters.new(valid_attendance)
      params_object = AttendanceParams.new(user, event, params)
      expect(params_object.new_attributes[:event_id]).to eq event.id
      expect(params_object.new_attributes[:user_id]).to eq user.id
      expect(params_object.new_attributes[:first_name]).to eq user.first_name
      expect(params_object.new_attributes[:last_name]).to eq user.last_name
      expect(params_object.new_attributes[:email]).to eq user.email
      expect(params_object.new_attributes[:organization]).to eq user.organization
      expect(params_object.new_attributes[:phone]).to eq user.phone
      expect(params_object.new_attributes[:country]).to eq user.country
      expect(params_object.new_attributes[:state]).to eq 'SC'
      expect(params_object.new_attributes[:city]).to eq user.city
      expect(params_object.new_attributes[:badge_name]).to eq user.badge_name
      expect(params_object.new_attributes[:cpf]).to eq user.cpf.numero

      expect(params_object.event).to eq event
      expect(params_object.user).to eq user
    end
  end

  describe '#payment_type_params' do
    it 'knows how to return the payment type params' do
      valid_attendance = { payment_type: 'bank_deposit' }

      params = ActionController::Parameters.new(valid_attendance)
      params_object = AttendanceParams.new(user, event, params)

      expect(params_object.payment_type_params).to eq 'bank_deposit'
    end
  end

  describe '#attributes_hash' do
    it 'returns the hash with the attributes' do
      valid_attendance = { attendance:
                             {
                               event_id: event.id,
                               user_id: user.id,
                               first_name: user.first_name,
                               last_name: user.last_name,
                               email: user.email,
                               organization: user.organization,
                               phone: user.phone,
                               country: user.country,
                               state: user.state,
                               city: user.city,
                               badge_name: user.badge_name,
                               cpf: user.cpf,
                               gender: user.gender
                             } }

      params = ActionController::Parameters.new(valid_attendance)
      params_object = AttendanceParams.new(user, event, params)
      expected_return = {
        'event_id' => event.id,
        'user_id' => user.id,
        'first_name' => user.first_name,
        'last_name' => user.last_name,
        'email' => user.email,
        'organization' => user.organization,
        'phone' => user.phone,
        'country' => user.country,
        'state' => user.state,
        'city' => user.city,
        'badge_name' => user.badge_name,
        'gender' => user.gender
      }

      expect(params_object.attributes_hash.to_h).to eq expected_return
    end
  end
end
