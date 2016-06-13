# frozen_string_literal: true
# TODO: move to a validator
def checker(from, of, nesting)
  assert_not_nil from, nesting
  from.each_pair do |key, val|
    if val.is_a?(String) || val.is_a?(Integer) || val.is_a?(TrueClass) || val.is_a?(FalseClass)
      assert_equal val, of[key], "#{nesting}>#{key}"
    elsif val.nil?
      assert_nil of[key]
    elsif of.is_a?(Array)
      checker val, of[0][key], "#{nesting}>#{key}"
    else
      checker val, of[key], "#{nesting}>#{key}"
    end
  end
end

Then(/^the fields match:$/) do |against|
  checker JSON.parse(Confidence.client.hydrater(against)), Confidence.client['data'], ''
end

Then(/^the fields match:$/) do |against|
  against = JSON.parse(Confidence.client.hydrater(against))
  Confidence.client.last_body[resource].each do |body|
    checker against, body, ''
  end
end