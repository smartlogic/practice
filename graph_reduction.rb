# Graph Reduction
# Exercise carried by Nick Gauthier, Adam Bachman and John Trupiano
# Tuesday, April 20, 2010
#
# In Nomtracker we would like to do automatic debt reduction.  This spike
# addresses that problem in an independent context.

require 'ruby-debug'
require 'pp'

def find_first_chain(debts)
  # you owe somebody who owes somebody else
  debts.keys.each {|node|
    ret = debts[node].keys.detect {|second_node|
      debts.has_key?(second_node) && node != second_node
    }
    return [node, ret, debts[ret].keys.first] unless ret.nil?
  }
  nil
end

def min_edge_length(debts, chain)
  min = 10000000
  chain.each_cons(2) do |(from, to)|
    # debugger
    min = debts[from][to] if min > debts[from][to]
  end
  min
end

def reduce(debts)
  while chain = find_first_chain(debts)
    reduce_by = min_edge_length(debts, chain)
    chain.each_cons(2) do |(from,to)|
      # debugger
      debts[from][to] -= reduce_by
      debts[from].delete(to) if debts[from][to].zero?
    end
    if chain[0] != chain[-1]
      debts[chain[0]][chain[-1]] ||= 0
      debts[chain[0]][chain[-1]] += reduce_by
    end
    debts.keys.each do |node|
      debts.delete(node) if debts[node].empty?
    end
  end
  debts
end

require 'test/unit'
class CycleTest < Test::Unit::TestCase

  def test_0
    debts = {
      'a' => {'b' => 1},
      'b' => {'a' => 1}
    }
    exp_results = {}
    assert_equal exp_results, reduce(debts)
  end

  def test_0b
    debts = {
      'a' => {'b' => 1},
      'b' => {'c' => 1},
      'c' => {'a' => 1}
    }
    exp_results = {}
    assert_equal exp_results, reduce(debts)
  end
  
  def test_1
    debts = {
      "a" => {"b" => 1},
      "b" => {"c" => 2}
    }
    
    exp_results = {
      "a" => {"c" => 1},
      "b" => {"c" => 1}
    }
    assert_equal exp_results, reduce(debts)
  end

  def test_2
    debts = {
      "a" => {"b" => 2},
      "b" => {"c" => 3}
    }
    
    exp_results = {
      "a" => {"c" => 2},
      "b" => {"c" => 1}
    }
    assert_equal exp_results, reduce(debts)
  end

  def test_3
    debts = {
      "a" => {"b" => 1},
      "b" => {"c" => 2},
      "c" => {"d" => 3}
    }
    
    exp_results = {
      "a" => {"d" => 1},
      "b" => {"d" => 1},
      "c" => {"d" => 1}
    }
    assert_equal exp_results, reduce(debts)
  end
  
  def test_4
    debts = {
      'a' => {'b' => 3},
      'b' => {'c' => 5, 'd' => 2},
      'c' => {'a' => 5},
      'd' => {'a' => 2}
    }
    exp_results = {'b' => {'a' => 4}}
    assert_equal exp_results, reduce(debts)
  end
  
  def test_5
    debts = {
      'a' => {'b' => 5, 'd' => 2},
      'b' => {'c' => 5},
      'c' => {'a' => 3},
      'd' => {'c' => 2}
    }
    exp_results = {'a' => {'c' => 4}}
    assert_equal exp_results, reduce(debts)
  end
  
  def test_6
    debts = {
      'a' => {'b' => 1},
      'b' => {'c' => 2},
      'd' => {'b' => 2}
    }
    exp_results = {
      'a' => {'b' => 1},
      'd' => {'c' => 2}
    }
    assert_equal exp_results, reduce(debts)
  end
end