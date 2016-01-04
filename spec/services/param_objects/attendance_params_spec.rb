describe AttendanceParams, type: :param_object do
  let(:user) { FactoryGirl.create :user }
  let(:event) { FactoryGirl.create :event }

  describe '#new_attributes' do
    it 'returns all parameters for attendance' do
      valid_attendance =
        {
          event_id: event.id,
          user_id: user.id,
          first_name: user.first_name,
          last_name: user.last_name,
          email: user.email,
          email_confirmation: user.email,
          organization: user.organization,
          phone: user.phone,
          country: user.country,
          state: user.state,
          city: user.city,
          badge_name: user.badge_name,
          cpf: user.cpf,
          gender: user.gender,
          twitter_user: user.twitter_user,
          address: user.address,
          neighbourhood: user.neighbourhood,
          zipcode: user.zipcode
        }
      now = Time.zone.now
      Time.stubs(:now).returns(now)
      params = ActionController::Parameters.new(valid_attendance)
      params_object = AttendanceParams.new(user, event, params)
      expect(params_object.new_attributes).to eq({ 'first_name' => user.first_name,
                                                   'last_name' => user.last_name,
                                                   'email' => user.email,
                                                   'organization' => user.organization,
                                                   'phone' => user.phone,
                                                   'country' => user.country,
                                                   'state' => user.state,
                                                   'city' => user.city,
                                                   'badge_name' => user.badge_name,
                                                   'cpf' => "#{user.cpf}",
                                                   'gender' => user.gender,
                                                   'twitter_user' => user.twitter_user,
                                                   'address' => user.address,
                                                   'neighbourhood' => user.neighbourhood,
                                                   'zipcode' => user.zipcode,
                                                   'registration_group_id' => nil,
                                                   :email_confirmation => user.email,
                                                   :event_id => event.id,
                                                   :user_id => user.id,
                                                   :registration_date => now })
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
                               email_confirmation: user.email,
                               organization: user.organization,
                               phone: user.phone,
                               country: user.country,
                               state: user.state,
                               city: user.city,
                               badge_name: user.badge_name,
                               cpf: user.cpf,
                               gender: user.gender,
                               twitter_user: user.twitter_user,
                               address: user.address,
                               neighbourhood: user.neighbourhood,
                               zipcode: user.zipcode
                             }
      }

      params = ActionController::Parameters.new(valid_attendance)
      params_object = AttendanceParams.new(user, event, params)
      expected_return = {
        'event_id' => event.id,
        'user_id' => user.id,
        'first_name' => user.first_name,
        'last_name' => user.last_name,
        'email' => user.email,
        'email_confirmation' => user.email,
        'organization' => user.organization,
        'phone' => user.phone,
        'country' => user.country,
        'state' => user.state,
        'city' => user.city,
        'badge_name' => user.badge_name,
        'gender' => user.gender,
        'twitter_user' => user.twitter_user,
        'address' => user.address,
        'neighbourhood' => user.neighbourhood,
        'zipcode' => user.zipcode }

      expect(params_object.attributes_hash).to eq expected_return
    end
  end
end