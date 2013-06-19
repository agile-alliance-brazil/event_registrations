# encoding: UTF-8
Event.seed do |event|
  event.id                   = 1
  event.name                 = 'Agile Brazil 2013'
  event.year                 = 2013
  event.location_and_date    = 'Brasília, DF'
  event.price_table_link     = 'http://www.agilebrazil.com/2013/:locale/inscricao/'
  event.allow_voting         = true
  event.attendance_limit     = 0
end

Event.seed do |event|
  event.id                   = 2
  event.name                 = 'Esquenta Agile Brazil - Agile Business Analysis'
  event.year                 = 2013
  event.location_and_date    = 'Brasília, DF'
  event.price_table_link     = 'http://www.agilebrazil.com/2013/:locale/viradaagil/'
  event.allow_voting         = false
  event.attendance_limit     = 25
end

Event.seed do |event|
  event.id                   = 3
  event.name                 = 'Virada Ágil - PSM - Professional Scrum Master - Lambda3'
  event.year                 = 2013
  event.location_and_date    = '24 & 25 Jun, Brasília, DF'
  event.price_table_link     = 'http://www.agilebrazil.com/2013/:locale/viradaagil/psm'
  event.allow_voting         = false
  event.attendance_limit     = 30
end

Event.seed do |event|
  event.id                   = 4
  event.name                 = 'Virada Ágil - Management 3.0 - Adaptworks'
  event.year                 = 2013
  event.location_and_date    = '20 & 21 Jun, Brasília, DF'
  event.price_table_link     = 'http://www.agilebrazil.com/2013/:locale/viradaagil/management-3-0'
  event.allow_voting         = false
  event.attendance_limit     = 30
end

Event.seed do |event|
  event.id                   = 5
  event.name                 = 'Virada Ágil - Kit para retrospectivas ágeis - ThoughtWorks'
  event.year                 = 2013
  event.location_and_date    = '25 Jun, Brasília, DF'
  event.price_table_link     = 'http://www.agilebrazil.com/2013/:locale/viradaagil/kit-para-retrospectivas-ageis'
  event.allow_voting         = false
  event.attendance_limit     = 20
end

Event.seed do |event|
  event.id                   = 6
  event.name                 = 'Virada Ágil - CSPO - Certified Product Owner - Massimus'
  event.year                 = 2013
  event.location_and_date    = '24 & 25 Jun, Brasília, DF'
  event.price_table_link     = 'http://www.agilebrazil.com/2013/:locale/viradaagil/cspo'
  event.allow_voting         = false
  event.attendance_limit     = 30
end

Event.seed do |event|
  event.id                   = 7
  event.name                 = 'Virada Ágil - Workshop de Testes & Refatoração - Industrial Logic'
  event.year                 = 2013
  event.location_and_date    = '24 & 25 Jun, Brasília, DF'
  event.price_table_link     = 'http://www.agilebrazil.com/2013/:locale/viradaagil/workshop-de-testes-refatoracao/'
  event.allow_voting         = false
  event.attendance_limit     = 22
end

Event.seed do |event|
  event.id                   = 8
  event.name                 = 'Virada Ágil - Práticas ágeis - Caelum'
  event.year                 = 2013
  event.location_and_date    = '24 & 25 Jun, Brasília, DF'
  event.price_table_link     = 'http://www.agilebrazil.com/2013/:locale/viradaagil/praticas-ageis'
  event.allow_voting         = false
  event.attendance_limit     = 20
end

Event.seed do |event|
  event.id                   = 9
  event.name                 = 'Virada Ágil - Lean Startup - SEA Tecnologia'
  event.year                 = 2013
  event.location_and_date    = '24 & 25 Jun, Brasília, DF'
  event.price_table_link     = 'http://www.agilebrazil.com/2013/:locale/viradaagil/lean-startup'
  event.allow_voting         = false
  event.attendance_limit     = 30
end

Event.seed do |event|
  event.id                   = 10
  event.name                 = 'Virada Ágil - Pirâmide Lean - OnCast'
  event.year                 = 2013
  event.location_and_date    = '24 & 25 Jun, Brasília, DF'
  event.price_table_link     = 'http://www.agilebrazil.com/2013/:locale/viradaagil/piramide-lean'
  event.allow_voting         = false
  event.attendance_limit     = 25
end

Event.seed do |event|
  event.id                   = 11
  event.name                 = 'Virada Ágil - Continuous Delivery - Dextraining'
  event.year                 = 2013
  event.location_and_date    = '22 & 23 Jun, Brasília, DF'
  event.price_table_link     = 'http://www.agilebrazil.com/2013/:locale/viradaagil/continuous-delivery'
  event.allow_voting         = false
  event.attendance_limit     = 30
end
