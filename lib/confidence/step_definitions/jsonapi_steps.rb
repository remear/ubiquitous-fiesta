# frozen_string_literal: true
When(/^I (\w+) to the (top|resource)\-level (\w+) link$/) do |verb, level, link|
  step "I #{verb} to the #{level}-level \"#{link}\" link with the body:", nil
end

When(/^I (\w+) to the (top|resource)\-level (\w+) link with the body:$/) do |verb, level, link, body|
  keys = case level
         when 'resource' then "data.links.#{link}"
         when 'top' then "links.#{link}"
           end
  step "I #{verb} to the \"#{keys}\" link with the body:", body
end