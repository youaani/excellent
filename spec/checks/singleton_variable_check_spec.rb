require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Simplabs::Excellent::Checks::SingletonVariableCheck do

  before(:each) do
    @excellent = Simplabs::Excellent::Runner.new(Simplabs::Excellent::Checks::SingletonVariableCheck.new)
  end

  describe '#evaluate' do

    it 'should reject singleton variables' do
      content = <<-END
        @@foo
      END
      @excellent.check_content(content)
      warnings = @excellent.warnings

      warnings.should_not be_empty
      warnings[0].info.should        == { :variable => 'foo' }
      warnings[0].line_number.should == 2
      warnings[0].message.should     == 'Singleton variable foo used.'
    end

    it 'should also work for namespaced classes' do
      content = <<-END
        module Outer
          module Inner
            class Class
              @@foo
            end
          end
        end
      END
      @excellent.check_content(content)
      warnings = @excellent.warnings

      warnings.should_not be_empty
      warnings[0].info.should        == { :variable => 'Outer::Inner::Class.foo' }
      warnings[0].line_number.should == 5
      warnings[0].message.should     == 'Singleton variable Outer::Inner::Class.foo used.'
    end

    it 'should also work for singleton variables that occur within methods' do
      content = <<-END
        module Outer
          module Inner
            class Class
              def method
                @@foo
              end
            end
          end
        end
      END
      @excellent.check_content(content)
      warnings = @excellent.warnings

      warnings.should_not be_empty
      warnings[0].info.should        == { :variable => 'Outer::Inner::Class.foo' }
      warnings[0].line_number.should == 6
      warnings[0].message.should     == 'Singleton variable Outer::Inner::Class.foo used.'
    end

  end

end
