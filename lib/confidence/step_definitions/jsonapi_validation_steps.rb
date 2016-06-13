Then(/^the attributes match:$/) do |against|
  checker JSON.parse(Confidence.client.hydrater(against)), Confidence.client['data']['attributes'], ''
end

Then(/^the errors match:$/) do |against|
  against = JSON.parse(Confidence.client.hydrater(against))
  Confidence.client['errors'].each do |error|
    checker against, error, ''
  end
end