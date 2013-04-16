# encoding: UTF-8
Event.seed do |event|
  event.id                   = 1
  event.name                 = 'Agile Brazil 2013'
  event.year                 = 2013
  event.location_and_date    = 'Brasília, DF'
  event.price_table_link     = 'http://www.agilebrazil.com/2013/:locale/inscricao/'
end
Event.seed do |event|
  event.id                   = 2
  event.name                 = 'Esquenta Agile Brazil - Agile Business Analysis'
  event.year                 = 2013
  event.location_and_date    = 'Brasília, DF'
  event.price_table_link     = 'http://www.agilebrazil.com/2013/:locale/viradaagil/'
end
