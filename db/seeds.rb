# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)
campaigns = [{
              name: 'lite',
              credit: 100,
              unit: 'sms',
              price: 0,
              currency_symbold: '฿',
              currency: 'Bath',
              popular: false,
              default: true,
              color: 'blue'
            },
            {
              name: 'startup',
              credit: 100,
              unit: 'sms',
              price: 150,
              currency_symbold: '฿',
              currency: 'Bath',
              popular: false,
              default: true,
              color: 'blue'
            },
            {
              name: 'standard',
              credit: 250,
              unit: 'sms',
              price: 300,
              currency_symbold: '฿',
              currency: 'Bath',
              popular: true,
              default: false,
              color: 'greenLight'
            },
            {
              name: 'premium',
              credit: 500,
              unit: 'sms',
              price: 450,
              currency_symbold: '฿',
              currency: 'Bath',
              popular: false,
              default: false,
              color:'redLight'
            },
            {
              name: 'gold',
              credit: 1000,
              unit: 'sms',
              price: 750,
              currency_symbold: '฿',
              currency: 'Bath',
              popular: false,
              default: false,
              color: 'orange'
            }]
campaigns.each do |campaign|
  c = Campaign.new
  c.name      = campaign[:name]
  c.credit    = campaign[:credit]
  c.unit      = campaign[:unit]
  c.price     = campaign[:price]
  c.currency  = campaign[:currency]
  c.currency_symbold = campaign[:currency_symbold]
  c.color     = campaign[:color]
  c.popular   = campaign[:popular]
  c.default   = campaign[:default]
  if c.save
    puts 'Campaign ' + campaign[:name] + ' created successfull.'
  else
    puts c.errors.full_messages
  end
end