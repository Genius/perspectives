require 'spec_helper'

describe Perspectives::Properties do
  module ::Users
    class Properties < Perspectives::Base
      param :user

      property(:name) { user.name }

      nested 'profile'

      nested_collection '/some_name_space/groups/show',
        collection: proc { user.groups },
        property: :groups
    end
  end

  module ::Users
    class Profile < Perspectives::Base
      delegate_property :blog_url, to: :user
    end
  end

  module ::SomeNameSpace
    class Group
      def name
        "a group"
      end
    end
    module Groups
      class Show < Perspectives::Base
        param :group
      end
    end
  end

  let(:context) { {} }
  let(:name) { 'Andrew Warner' }
  let(:blog_url) { 'a-warner.github.io' }
  let(:groups) do
    [
      SomeNameSpace::Group.new,
      SomeNameSpace::Group.new
    ]
  end
  let(:user) do
    OpenStruct.new :name => name, :groups => groups
  end

  let(:params) { {:user => user} }

  subject { ::Users::Properties.new(context, params) }

  its(:name) { should == 'Andrew Warner' }
  its(:profile) { should_not be_nil }

  describe '#groups' do
    it 'should return a non-nil value' do
      expect(subject.groups).not_to be_nil
    end
  end
end
