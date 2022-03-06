class Calculator

  attr_accessor :input

  BODMAS_RULE = ["(",")","/","*","+","-"]

  def operand_check(value)
    Float(value)
  rescue ArgumentError
    false
  end

  def calculate(input)
    input_array = seperator(input)
    result = process_BODMAS(input_array)
    p "The result is #{result || input_array.join}"
  end

  def seperator(input)
    input_array = input.split("")
    new_input = []
    elem = ''
  input_array.each do |e|
    if (BODMAS_RULE.include? e)
      if (elem.empty?)
        new_input << e
      else
        new_input << elem
        new_input << e
      end
      elem = ""
    else
      elem += e
    end
  end
  if (!elem.empty?) then new_input << elem end
  return new_input
  end

  def count_operators(input_array,operator)
    count_operator_hash = Hash.new(0)
      input_array.each {|value| count_operator_hash[value] += 1}
      count = count_operator_hash.select {|key,value| key == operator && value > 0}.values
      count.join("")
  end

  def sort_operands_and_operators(sub_array)
    negative_num_container = []
    new_sub_array = []
    sub_array.delete_if { |i| i == "(" || i == ")" }
    if (sub_array.first == '-')
      sub_array[0] = sub_array.shift + sub_array[0]
    end
    sub_array.map! do |value|
      if (operand_check(value)) && (value.to_f < 0)
        negative_num_container << value
        value = "true"
      else
        value
      end
    end
    sub_array_operands = sub_array.join.tr("/*+-"," ").split
    sub_array_operators = sub_array.join.tr("true1234567890."," ").split
    negative_num_container.reverse!
    sub_array_operands.map! do |value|
      if (value == "true")
        value = negative_num_container.pop
      else
        value
      end
    end
    counter = 0
    while (counter < sub_array_operands.length)
        new_sub_array << sub_array_operands[counter]
        if (counter < sub_array_operators.length)
          new_sub_array << sub_array_operators[counter]
        end
        counter += 1
    end
      return new_sub_array,sub_array_operators
  end

  def brackets_tracker(input_array)
    open_bracket,close_bracket,*others= BODMAS_RULE
    open_brackets_tracker = []
    close_brackets_tracker = []
    input_array.each_with_index do |value, index|
      if (value == open_bracket) then open_brackets_tracker << index end
      if (value == close_bracket) then close_brackets_tracker << index end
    end
    open_brackets_index = open_brackets_tracker.pop
    close_brackets_index = close_brackets_tracker.select {|e| e > open_brackets_index}.shift
    close_brackets_tracker.delete(close_brackets_index)
    return open_brackets_index,close_brackets_index
  end

  def process_BODMAS(input_array)
    open_bracket,close_bracket,*others = BODMAS_RULE
    sub_array = []
     if (!input_array.include? open_bracket)
       input_array = run_operation(sort_operands_and_operators(input_array))
       return input_array
     end
      while (input_array.length > 1)
        BODMAS_RULE.each do |value|
          if (input_array.include? open_bracket)
            while ((count_operators(input_array,open_bracket)).to_i > 0)
              start_index = brackets_tracker(input_array)[0]
              end_index = brackets_tracker(input_array)[1]
              sub_array = input_array.slice((start_index..end_index))
              input_array[start_index..end_index] = run_operation(sort_operands_and_operators(sub_array))
            end
          end
          if (input_array.include? value)
            while ((count_operators(input_array,value)).to_i > 0)
              index = input_array.find_index(value)
              sub_array = input_array.slice((index-1)..(index+1))
              input_array[(index-1)..(index+1)] = run_operation(sort_operands_and_operators(sub_array))
            end
          end
        end
      end
  end

  def run_operation(operations_array)
    sub_array = operations_array[0]
    operators_array = operations_array[1]
    result = 0
    if (sub_array.one?) && (operators_array.empty?) then return sub_array.pop end
    operators_array.sort! do |a,b|
      BODMAS_RULE.find_index(a) <=> BODMAS_RULE.find_index(b)
    end
    operators_array.each do |value|
      if (value != "-")
        first_index = sub_array.find_index(value) - 1
        second_index = sub_array.find_index(value) + 1
        result = sub_array[first_index..second_index] = sub_array[first_index].to_f.send(value, sub_array[second_index].to_f)
      elsif (value == "-") && (operand_check(sub_array[sub_array.find_index(value)-1]) == false)
        first_index = sub_array.find_index(value) + 2
        second_index = sub_array.find_index(value) + 1
        result = sub_array[(sub_array.find_index(value))..first_index] = sub_array[first_index].to_f.send(value, sub_array[second_index].to_f)
      else
        first_index = sub_array.find_index(value) - 1
        second_index = sub_array.find_index(value) + 1
        result = sub_array[first_index..second_index] = (sub_array[first_index].to_f.send(value, sub_array[second_index].to_f)).to_s
      end
    end
    result
  end
end

calculator_init = Calculator.new
calculator_init.calculate('3*4')
calculator_init.calculate('(((((16+16)))))')
calculator_init.calculate("(-30-6)")
calculator_init.calculate('99-(6-3)')
calculator_init.calculate("3+6")
calculator_init.calculate("(3-(16+16))")
calculator_init.calculate("3+6*5/3-4*(3-4)")
calculator_init.calculate("3+6*5/3-4*3-4")
calculator_init.calculate("(3+6)*5/3-4*(3-4)")
calculator_init.calculate("3+6*5/(13-4*3-4)")
