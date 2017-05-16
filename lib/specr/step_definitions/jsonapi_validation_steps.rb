Then(/^the attributes match:$/) do |against|
  checker JSON.parse(Specr.client.hydrater(against)), Specr.client['data']['attributes'], ''
end

Then(/^the errors match:$/) do |against|
  against = JSON.parse(Specr.client.hydrater(against))
  Specr.client['errors'].each do |error|
    checker against, error, ''
  end
end
