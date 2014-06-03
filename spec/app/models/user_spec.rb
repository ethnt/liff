require 'spec_helper'

describe User do
  let(:user) { create :user }

  it { expect(user).to be_valid }

  it { should validate_presence_of :name }
  it { should validate_presence_of :username }
  it { should validate_presence_of :email }
end
