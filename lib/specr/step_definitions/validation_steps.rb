# frozen_string_literal: true
# TODO: move to a validator
def checker(expected, actual, nesting)
  case expected
  when String, Integer, TrueClass, FalseClass
    assert_equal expected, actual, nesting
  when NilClass
    assert_nil actual, nesting
  when Hash
    expected.each_pair do |key, val|
      checker val, actual[key], "#{nesting}>#{key}"
    end
  when Array
    assert actual.is_a?(Array), nesting
    assert_empty(actual, nesting) if expected.empty?
    expected.each_with_index do |val, index|
      assert includes_match(actual, val), "#{nesting}>#{index}"
    end
  else
    flunk "different types (#{expected.class} and #{actual.class}) at #{nesting}"
  end
end

def includes_match(list, sought)
  list.any? { |list_element| matches(sought, list_element) }
end

def matches(expected, actual)
  case expected
  when String, Integer, TrueClass, FalseClass
    expected == actual
  when NilClass
    actual.nil?
  when Hash
    expected.all? do |key, val|
      matches val, actual[key]
    end
  when Array
    actual.is_a?(Array) && expected.all? do |expected_element|
      includes_match(actual, expected_element)
    end
  else
    false
  end
end

Then(/^the response (?:matches|contains):$/) do |expected|
  checker JSON.parse(Specr.client.hydrater(expected)), Specr.client.last_body, ''
end

Given(/^the response (\S+) collection does not contain:$/) do |path, unexpected_json|
  parts = path.split('.')
  unexpected = JSON.parse(Specr.client.hydrater(unexpected_json))
  actual = Specr.client.last_body.dig(*parts)
  unexpected.each do |i|
    refute_includes actual, i
  end
end
