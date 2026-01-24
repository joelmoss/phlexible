# frozen_string_literal: true

require 'test_helper'

class Phlexible::VersionTest < ActiveSupport::TestCase
  it 'has a major.minor.patch version' do
    assert_match(/\d+\.\d+\.\d+/, Phlexible::VERSION)
  end
end
