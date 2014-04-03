require 'spec_helper'

describe LinearPerspective::Properties do
  module ::Users
    class Properties < LinearPerspective::Base
      param :user

      property(:name) { user.name }

      nested 'profile'
    end
  end

  module ::Users
    class Profile < LinearPerspective::Base
      delegate_property :blog_url, to: :user
    end
  end

  let(:context) { OpenStruct.new }
  let(:name) { 'Andrew Warner' }
  let(:blog_url) { 'a-warner.github.io' }
  let(:user) { OpenStruct.new :name => name }

  let(:params) { {:user => user} }

  subject { ::Users::Properties.new(context, params) }

  its(:name) { should == 'Andrew Warner' }
  its(:profile) { should_not be_nil }
end
