require 'spec_helper'

describe Perspectives::Outputs do
  module ::Users
    class Properties < Perspectives::Base
      input :user

      output(:name) { user.name }

      nested 'profile'
    end
  end

  module ::Users
    class Profile < Perspectives::Base
      delegate_output :blog_url, to: :user
    end
  end

  let(:context) { {} }
  let(:name) { 'Andrew Warner' }
  let(:blog_url) { 'a-warner.github.io' }
  let(:user) { OpenStruct.new :name => name }

  let(:inputs) { {:user => user} }

  subject { ::Users::Properties.new(context, inputs) }

  its(:name) { should == 'Andrew Warner' }
  its(:profile) { should_not be_nil }
end
