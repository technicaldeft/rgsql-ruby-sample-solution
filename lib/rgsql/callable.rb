module RgSql
  Callable = Data.define(:name, :input_types, :output_type, :body)

  class Callable
    include Nodes

    OPERATORS = [
      new('+', [[Int, Int]], Int,        ->(op1, op2)       { Int.new(op1.value + op2.value) }),
      new('-', [[Int, Int], [Int]], Int, ->(op1, op2 = nil) { Int.new(op2 ? op1.value - op2.value : -op1.value) }),
      new('*', [[Int, Int]], Int,        ->(op1, op2)       { Int.new(op1.value * op2.value) }),
      new('/', [[Int, Int]], Int,        ->(op1, op2)       { Int.new(op1.value / op2.value) }),

      new('NOT', [[Bool]], Bool,       ->(op)       { Bool.new(!op.value) }),
      new('AND', [[Bool, Bool]], Bool, ->(op1, op2) { Bool.new(op1.value && op2.value) }),
      new('OR',  [[Bool, Bool]], Bool, ->(op1, op2) { Bool.new(op1.value || op2.value) }),

      new('<',  [[Bool, Bool], [Int, Int]], Bool, ->(op1, op2) { Bool.new(op1.to_i < op2.to_i) }),
      new('>',  [[Bool, Bool], [Int, Int]], Bool, ->(op1, op2) { Bool.new(op1.to_i > op2.to_i) }),
      new('>=', [[Bool, Bool], [Int, Int]], Bool, ->(op1, op2) { Bool.new(op1.to_i >= op2.to_i) }),
      new('<=', [[Bool, Bool], [Int, Int]], Bool, ->(op1, op2) { Bool.new(op1.to_i <= op2.to_i) }),

      new('=',  [[Bool, Bool], [Int, Int]], Bool, ->(op1, op2) { Bool.new(op1.value == op2.value) }),
      new('<>', [[Bool, Bool], [Int, Int]], Bool, ->(op1, op2) { Bool.new(op1.value != op2.value) })
    ].freeze

    FUNCTIONS = [
      new('ABS', [[Int]],      Int, ->(arg)        { Int.new(arg.value.abs) }),
      new('MOD', [[Int, Int]], Int, ->(arg1, arg2) { Int.new(arg1.value % arg2.value) })
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
      body.call(*inputs)
    end

    def accepts_types?(types)
      input_types.include?(types)
    end
  end
end
