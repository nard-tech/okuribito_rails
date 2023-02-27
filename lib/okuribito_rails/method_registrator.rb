require "yaml"

module OkuribitoRails
  class MethodRegistrator
    class << self
      def execute(yaml_file_path)
        new(yaml_file_path).execute
      end

      private :new
    end

    def initialize(yaml_file_path)
      @yaml_file_path = yaml_file_path
    end

    def execute
      full_method_names_to_register.each { |full_method_name| MethodCallSituation.register(full_method_name) }
      full_method_names_to_destroy.each { |full_method_name| MethodCallSituation.remove(full_method_name) }
    end

    private

    attr_reader :yaml_file_path

    def observed_methods_from_yaml
      return @observed_methods_from_yaml if defined?(@observed_methods_from_yaml)

      yaml = YAML.load_file(yaml_file_path)

      full_method_names = []

      yaml.each do |class_name, observed_methods|
        observed_methods.each do |observed_method|
          full_method_name = [class_name, observed_method].join
          full_method_names.push(full_method_name)
        end
      end

      @observed_methods_from_yaml = full_method_names
    end

    def methods_already_registered
      @methods_already_registered ||= MethodCallSituation.all.map(&:full_method_name)
    end

    def full_method_names_to_register
      observed_methods_from_yaml - methods_already_registered
    end

    def full_method_names_to_destroy
      methods_already_registered - observed_methods_from_yaml
    end
  end
end
