module YamlVault
  module YAMLCompat
    refine YAML.singleton_class do
      def load(yaml, **kw)
        if YAML.respond_to?(:unsafe_load)
          YAML.unsafe_load(yaml, **kw)
        else
          super(yaml, **kw)
        end
      end

      def load_file(filename, **kw)
        if YAML.respond_to?(:unsafe_load_file)
          YAML.unsafe_load_file(filename, **kw)
        else
          super(filename, **kw)
        end
      end
    end
  end
end
