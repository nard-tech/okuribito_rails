require "yaml"

module OkuribitoRails
  class MethodRegistrator
    def update_observe_methods(path)
      input = yaml_to_array(path)

      new_methods = input - methods_already_registered
      new_methods.each { |new_method| register_method(new_method) }
      old_methods = methods_already_registered - input
      old_methods.each { |old_method| destroy_method(old_method) }
    end

    private

    def yaml_to_array(path)
      yaml = YAML.load_file(path)
      methods_array = []
      yaml.each do |class_name, observe_methods|
        observe_methods.each do |observe_method|
          methods_array.push(class_name + observe_method)
        end
      end
      methods_array
    end

    def methods_already_registered
      @methods_already_registered ||= MethodCallSituation.all.map(&:full_method_name)
    end

    def register_method(method)
      a = method.split(/\s*(#|\.)\s*/)
      MethodCallSituation.create(class_name: a[0], method_symbol: a[1], method_name: a[2])
    end

    def destroy_method(method)
      a = method.split(/\s*(#|\.)\s*/)
      MethodCallSituation.find_by(class_name: a[0], method_symbol: a[1], method_name: a[2]).destroy
    end
  end
end
