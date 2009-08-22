module Gena
  class MethodAdder

    def self.add(noun, methods_hash)
      methods_hash.each_pair do |verb, prc|
        method_name = "__#{verb}_#{noun}"
        puts method_name
        define_method(method_name, prc)

        unless method_defined?(verb)
          puts "method not defined '#{verb}'"
          define_method(verb, prc_buf = proc {|*syms|
            if syms.count >= 2
              syms.each do |sym|
                res = prc_buf.call(sym)
                return res if res
              end
              return nil
            elsif syms.count == 1
              sym = syms.first
              return __send__("__#{verb}_#{sym}")
            else
              return nil
            end
          })
        end
      end
    end

  end
end
