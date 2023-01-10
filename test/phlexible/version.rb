# frozen_string_literal: true

describe Phlexible::VERSION do
  it 'has a major.minor.patch version' do
    expect(subject).to be =~ /\d+\.\d+\.\d+/
  end
end
