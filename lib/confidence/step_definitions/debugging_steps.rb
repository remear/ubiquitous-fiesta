# frozen_string_literal: true
Then(/^debug$/) do
  Confidence.logger.debug "HTTP status code: #{@client.last_code}"
  Confidence.logger.debug "HTTP body: #{@client.last_body}"
  Confidence.logger.debug "Storage: #{@client.storage}"
end

When(/^debugging is enabled$/) do
  Confidence.logger.level = Logger::DEBUG
end

When(/^debugging is disabled$/) do
  Confidence.logger.level = Logger::FATAL
end
