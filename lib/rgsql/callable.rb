module RgSql
  Callable = Data.define(:name, :input_types, :output_type, :body, :propagate_null?)

  class Callable
    include Nodes

    MINUS_BODY = lambda { |op1, op2 = nil|
      if op2
        Int.new(op1.value - op2.value)
      else
        Int.new(-op1.value)
      end
    }

    AND_BODY = lambda { |op1, op2|
      result = op1.value && op2.value
      if result.nil?
        Null.new
      else
        Bool.new(result)
      end
    }

    OR_BODY = lambda { |op1, op2|
      result = op1.value || op2.value
      if result.nil?
        Null.new
      else
        Bool.new(result)
      end
    }

    OPERATORS = [
      new('+', [[Int, Int]], Int,        ->(op1, op2) { Int.new(op1.value + op2.value) },       true),
      new('-', [[Int, Int], [Int]], Int, MINUS_BODY,                                            true),
      new('*', [[Int, Int]], Int,        ->(op1, op2)       { Int.new(op1.value * op2.value) }, true),
      new('/', [[Int, Int]], Int,        ->(op1, op2)       { Int.new(op1.value / op2.value) }, true),

      new('NOT', [[Bool]], Bool,        ->(op) { Bool.new(!op.value) }, true),
      new('AND', [[Bool, Bool]], Bool,  AND_BODY,                       false),
      new('OR',  [[Bool, Bool]], Bool,  OR_BODY,                        false),

      new('<',  [[Bool, Bool], [Int, Int]], Bool, ->(op1, op2) { Bool.new(op1.to_i < op2.to_i) },  true),
      new('>',  [[Bool, Bool], [Int, Int]], Bool, ->(op1, op2) { Bool.new(op1.to_i > op2.to_i) },  true),
      new('>=', [[Bool, Bool], [Int, Int]], Bool, ->(op1, op2) { Bool.new(op1.to_i >= op2.to_i) }, true),
      new('<=', [[Bool, Bool], [Int, Int]], Bool, ->(op1, op2) { Bool.new(op1.to_i <= op2.to_i) }, true),

      new('=',  [[Bool, Bool], [Int, Int]], Bool, ->(op1, op2) { Bool.new(op1.value == op2.value) }, true),
      new('<>', [[Bool, Bool], [Int, Int]], Bool, ->(op1, op2) { Bool.new(op1.value != op2.value) }, true)
    ].freeze

    FUNCTIONS = [
      new('ABS', [[Int]],      Int, ->(arg)        { Int.new(arg.value.abs) }, true),
      new('MOD', [[Int, Int]], Int, ->(arg1, arg2) { Int.new(arg1.value % arg2.value) }, true)
    ].freeze

    def self.find_operator(name)
      operator = OPERATORS.find { |callable| callable.name == name }
      operator || raise(ValidationError, "Cannot find operator #{name}")
    end

    def self.find_function(name)
      function = FUNCTIONS.find { |callable| callable.name == name }
      function || raise(ValidationError, "Cannot find function #{name}")
    end

    def call(inputs)
      if propagate_null? && inputs.any? { |input| input.is_a?(Null) }
        Null.new
      else
        body.call(*inputs)
      end
    end

    def accepts_types?(types)
      input_types.any? { |input_type| Types.all_match?(input_type, types) }
    end
  end
end
