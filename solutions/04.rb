module Asm
  def self.asm(&block)
    memory = Memory.new
    memory.instance_eval(&block)
    memory._methods
    memory.table.values.take(4)

  end

  class Memory
    attr_reader :table

    VALID_METHODS =
    [
      :mov, :cmp, :inc, :dec, :label,
      :jmp, :je, :jne, :jl, :jle, :jg, :jge
    ]

    JUMPS =
    {
      jmp: :+,
      je: :==,
      jne: :!=,
      jl: :<,
      jle: :<=,
      jg: :>,
      jge: :>=
    }

    def initialize
      @table = Hash.new { |hash,key| hash[key] = key }
      @table.merge!({ ax: 0, bx: 0, cx: 0, dx: 0 })
      @method_index, @method_queue = 0,{}
      @labels = Hash.new { |hash, key| hash[key] = key if key.is_a? Fixnum}
      @last_cmp = 0
    end

    def _mov(destination_register, source)
      @table[destination_register] = @table[source]
    end

    def _inc(destination_register, value = 1)
      @table[destination_register] += @table[value]
    end

    def _dec(destination_register, value = 1)
      @table[destination_register] -= @table[value]
    end

    def _cmp(register, value)
      @last_cmp = @table[register] <=> @table[value]
    end

    def _jump(jump_type,label_index,current_index)
      if @last_cmp.public_send(JUMPS[jump_type],0)
        _methods(label_index)
      else
        _methods(current_index + 1)
      end
    end

    def method_missing(name, *args)
      if name.to_s == 'label'.freeze
        @labels[args.first] = @method_index
      end
      if VALID_METHODS.include? name
        @method_queue[@method_index] = [name,args]
        @method_index += 1
      end
      name
    end

    def _methods(start_index = 0)
      @method_queue.keys[start_index..-1].each do |key|
        if(@method_queue[key].first.to_s.start_with? 'j')
          public_send(
            '_jump'.freeze,@method_queue[key][0],
            @labels[@method_queue[key][1][0]],key)
          break
        else
          public_send("_" + @method_queue[key][0].to_s,*@method_queue[key][1])
        end
      end
    end
  end
end
