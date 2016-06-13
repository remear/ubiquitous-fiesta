# frozen_string_literal: true
When /^I set headers:$/ do |request_headers|
  Confidence.client.headers = Confidence.configuration.default_headers.merge(request_headers.rows_hash)
end

When(/^I (\w+) to ((?:https?:\/)?\/\S*)$/) do |verb, url|
  Confidence.client.send(verb.downcase, url)
end

When(/^I (\w+) to ((?:https?:\/)?\/\S*) with the body:$/) do |verb, url, body|
  Confidence.client.send(verb.downcase.to_sym, url, body)
end

When(/^I (POST|PATCH) to (\/\S*?) with the file "(.*?)" as "(.*?)"$/) do |verb, url, file, file_field|
  Confidence.client.send("#{verb.downcase}_multipart",
                         Confidence.client.hydrater(url), file, file_field, nil)
end

When(/^I (POST|PATCH) to (\/\S*?) with the "(.*?)" file as "(.*?)" and the body:$/) do |verb, url, file, file_field, body|
  Confidence.client.send("#{verb.downcase}_multipart",
                         Confidence.client.hydrater(url), file, file_field, body)
end

When(/^I (\w+) to the "(.*?)" link with the body:$/) do |verb, keys, body|
  step "I #{verb} to #{Confidence.client.get_link(keys)} with the body:", body
end

When(/^I (\w+) to the "(.*?)" link$/) do |verb, keys|
  step "I #{verb} to #{Confidence.client.get_link(keys)}"
end

Then(/^the response has this schema:$/) do |schema|
  Confidence.client.validate(schema)
end

Then(/^the response is valid according to the "(.*?)" schema$/) do |filename|
  Confidence.client.validate(filename)
end

Then(/^I should get a (.+) status code$/) do |code|
  message = Confidence.client.last_body.fetch('description', '') if Confidence.client.last_body
  assert_equal code.to_i, Confidence.client.last_code, message
end

Then(/^there should be no response body$/) do
  assert_nil Confidence.client.last_body
end
