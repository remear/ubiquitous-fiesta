# frozen_string_literal: true
Then(/^debug$/) do
  Specr.logger.debug "HTTP status code: #{@client.last_code}"
  Specr.logger.debug "HTTP body: #{@client.last_body}"
  Specr.logger.debug "Storage: #{@client.storage}"
end

When(/^debugging is enabled$/) do
  Specr.logger.level = Logger::DEBUG
end

When(/^debugging is disabled$/) do
  Specr.logger.level = Logger::FATAL
end
