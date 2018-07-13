Then(/^the data matches:$/) do |expected|
  checker JSON.parse(Specr.client.hydrater(expected)), Specr.client['data'], ''
end

Then(/^the attributes match:$/) do |expected|
  checker JSON.parse(Specr.client.hydrater(expected)), Specr.client['data']['attributes'], ''
end

Then(/^the errors match:$/) do |expected|
  expected = JSON.parse(Specr.client.hydrater(expected))
  Specr.client['errors'].each do |error|
    checker expected, error, ''
  end
end
