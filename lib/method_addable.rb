module Gena
  class MethodAddable

    def self.add(noun, methods_hash)
      methods_hash.each_pair do |verb, prc|
        method_name = "__#{verb}_#{noun}"
        define_method(method_name, prc)

        unless method_defined?(verb)
          define_method(verb, proc {|*syms|
            if syms.count >= 2
              syms.each do |sym|
                res = __send__(verb, sym)
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
