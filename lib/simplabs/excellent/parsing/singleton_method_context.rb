module Simplabs

  module Excellent

    module Parsing

      class SingletonMethodContext < MethodContext

        ASSIGNMENTS       = [:lasgn]
        BRANCHES          = [:vcall, :call]
        CONDITIONS        = [:==, :<=, :>=, :<, :>]
        OPERATORS         = [:*, :/, :%, :+, :<<, :>>, :&, :|, :^, :-, :**]
        COMPLEXITY_NODE_TYPES = [:if, :while, :until, :for, :rescue, :case, :when, :and, :or]

        attr_reader :parameters
        attr_reader :abc_score
        attr_reader :cc_score

        def initialize(exp, parent)
          super
          @name = exp[2].to_s
          @abc_score = count_abc_score
          @cc_score  = count_cyclomytic_complexity + 1
        end

        def full_name
          return @name if @parent.blank?
          "#{@parent.full_name}.#{@name}"
        end

        private

          def count_cyclomytic_complexity(exp = @exp)
            count = 0
            count = count + 1 if COMPLEXITY_NODE_TYPES.include?(exp.node_type)
            exp.children.each { |child| count += count_cyclomytic_complexity(child) }
            count
          end

          def count_abc_score
            a = count_assignments
            b = count_branches
            c = count_conditionals
            score = Math.sqrt(a * a + b * b + c * c)
          end

          def count_assignments(exp = @exp)
            count = 0
            count = count + 1 if assignment?(exp)
            exp.children.each { |exp| count += count_assignments(exp) }
            count
          end

          def count_branches(exp = @exp)
            count = 0
            count = count + 1 if branch?(exp)
            exp.children.each { |exp| count += count_branches(exp) }
            count
          end

          def count_conditionals(exp = @exp)
            count = 0
            count = count + 1 if conditional?(exp)
            exp.children.each { |exp| count += count_conditionals(exp) }
            count
          end

          def assignment?(exp)
            ASSIGNMENTS.include?(exp.node_type)
          end

          def branch?(exp)
            BRANCHES.include?(exp.node_type) && !conditional?(exp) && !operator?(exp)
          end

          def conditional?(exp)
            (:call == exp.node_type) && CONDITIONS.include?(exp[2]) 
          end

          def operator?(exp)
            (:call == exp.node_type) && OPERATORS.include?(exp[2]) 
          end

      end

    end

  end

end
