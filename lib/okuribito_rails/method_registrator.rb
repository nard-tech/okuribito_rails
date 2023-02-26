require "yaml"

module OkuribitoRails
  class MethodRegistrator
    def update_observe_methods(path)
      methods_from_yaml = observed_methods_from_yaml(path)

      full_method_names_to_register = methods_from_yaml - methods_already_registered
      full_method_names_to_register.each { |full_method_name| register_method(full_method_name) }

      full_method_names_to_remove = methods_already_registered - methods_from_yaml
      full_method_names_to_remove.each { |full_method_name| destroy_method(full_method_name) }
    end

    private

    def observed_methods_from_yaml(path)
      yaml = YAML.load_file(path)

      full_method_names = []

      yaml.each do |class_name, observed_methods|
        observed_methods.each do |observed_method|
          full_method_name = [class_name, observed_method].join
          full_method_names.push(full_method_name)
        end
      end

      full_method_names
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
