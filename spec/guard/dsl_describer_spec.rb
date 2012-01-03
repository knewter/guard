require 'spec_helper'

describe Guard::DslDescriber do

  let(:describer) { ::Guard::DslDescriber }

  let(:guardfile) do
    <<-GUARD
      guard :test, :a => :b do
        watch('c')
      end

      group :a do
        guard 'test', :x => 1 do
          watch('c')
        end
      end

      group "b" do
        guard :another do
          watch('c')
        end
      end
    GUARD
  end

  before do
    @output = ''
    Guard::UI.stub(:info) { |msg| @output << msg + "\n" }
  end

  after do
    Guard::UI.unstub(:info)
  end

  describe '.list' do
    it "lists the available Guards when they're declared as strings or symbols" do
      Guard.stub(:guard_gem_names).and_return ['test', 'another', 'even', 'more']
      describer.list(:guardfile_contents => guardfile)
      @output.should eql <<OUTPUT
Using inline Guardfile.
Available guards:
   another*
   even
   more
   test*

See also https://github.com/guard/guard/wiki/List-of-available-Guards
* denotes ones already in your Guardfile
OUTPUT
    end
  end

  describe '.show' do
    it 'shows the Guards and their options' do
      describer.show(:guardfile_contents => guardfile)
      @output.should eql <<OUTPUT
Using inline Guardfile.
(global):
  test: a => :b
Group a:
  test: x => 1
Group b:
  another

OUTPUT
    end
  end

end
