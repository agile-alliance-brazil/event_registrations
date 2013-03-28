# encoding: UTF-8
RegistrationType.seed do |registration_type|
  registration_type.event_id = 1
  registration_type.id = 1
  registration_type.title = 'registration_type.individual'
end

RegistrationType.seed do |registration_type|
  registration_type.event_id = 1
  registration_type.id = 2
  registration_type.title = 'registration_type.group'
end

RegistrationType.seed do |registration_type|
  registration_type.event_id = 1
  registration_type.id = 3
  registration_type.title = 'registration_type.free'
end

RegistrationType.seed do |registration_type|
  registration_type.event_id = 1
  registration_type.id = 4
  registration_type.title = 'registration_type.manual'
end
