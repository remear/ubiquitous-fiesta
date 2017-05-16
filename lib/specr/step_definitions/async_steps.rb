# frozen_string_literal: true
And(/^I await processing for ((?:https?:\/)?\/\S*) with the condition "(\S*?)" "(\S*)" "(.*?)"$/) do |url, keys, comperator, value|
  await_resource_processing(url, comperator, keys, value)
end

def await_resource_processing(href, comperator, watched_attribute, desired_value)
  attempts = 0
  max_attempts = 5
  pending = true
  response = nil
  begin
    response = JSON.parse(Specr.client.get(href))
    current_value = Specr.client.get_link(watched_attribute)
    if current_value.method(comperator).call(desired_value)
      pending = false
    else
      sleep 5
    end
    attempts += 1
  end while pending && (attempts < max_attempts)
  raise ArgumentError, 'Timed out waiting for resource processing!' if pending == true
  response
end
