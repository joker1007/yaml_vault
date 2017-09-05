# frozen_string_literal: false
require 'yaml'

module YamlVault
  class EncryptedTreeBuilder < YAML::TreeBuilder
    def initialize(target_paths, cryptor)
      super()
      @target_paths = target_paths
      @path_stack = []
      @cryptor = cryptor
    end

    def start_document(version, tag_directives, implicit)
      result = super
      @path_stack.push "$"
      result
    end

    def end_document(*)
      @path_stack.pop
      super
    end

    def end_mapping(*)
      @path_stack.pop
      super
    end

    def end_sequence(*)
      @path_stack.pop
      super
    end

    def scalar(value, anchor, tag, plain, quoted, style)
      result = super

      case @last
      when YAML::Nodes::Sequence
        current_path = @last.children.size - 1
        @path_stack << current_path
      when YAML::Nodes::Mapping
        if @last.children.size.odd?
          @path_stack << value
          return result
        end
      end

      if match_path?
        result.value = @cryptor.encrypt(value)
      end

      @path_stack.pop

      result
    end

    def alias(anchor)
      @path_stack.pop
      super
    end

    private

    def match_path?
      @target_paths.any? do |target_path|
        target_path.each_with_index.all? do |path, i|
          if path == "*"
            true
          else
            path == @path_stack[i]
          end
        end
      end
    end
  end
end
