# frozen_string_literal: true
And(/^I await processing for ((?:https?:\/)?\/\S*) with the condition "(\S*?)" "(\S*)" "(.*?)"$/) do |url, keys, comperator, value|
  await_resource_processing(url, comperator, keys, value)
end

def await_resource_processing(href, comperator, watched_attribute, desired_value)
  attempts = 0
  max_attempts = ENV.fetch('SPECR_MAX_AWAIT_RETRIES', 10).to_i
  pending = true
  response = nil
  begin
    response = Specr.client.get(href)
    current_value = Specr.client.get_link(watched_attribute)
    if current_value.method(comperator).call(desired_value)
      pending = false
    else
      Specr.logger.debug "Retrying..."
      sleep ENV.fetch('SPECR_AWAIT_SLEEP', 5).to_i
    end
    attempts += 1
  end while pending && (attempts < max_attempts)
  raise RuntimeError, 'Timed out waiting for resource processing!' if pending == true
  response
end
