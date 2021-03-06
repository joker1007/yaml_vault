# frozen_string_literal: false
require 'yaml'

module YamlVault
  class YAMLTreeBuilder < YAML::TreeBuilder
    def initialize(target_paths, prefix, suffix, cryptor, mode)
      super()

      @path_stack = []
      @target_paths = target_paths
      @prefix = prefix
      @suffix = suffix
      @cryptor = cryptor
      @mode = mode
    end

    def start_document(*)
      result = super
      @path_stack.push "$"
      result
    end

    def end_document(*)
      @path_stack.pop
      super
    end

    def start_mapping(*)
      if YAML::Nodes::Sequence === @last
        current_path = @last.children.size
        @path_stack << current_path
      end

      super
    end

    def end_mapping(*)
      @path_stack.pop
      super
    end

    def start_sequence(*)
      if YAML::Nodes::Sequence === @last
        current_path = @last.children.size
        @path_stack << current_path
      end

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
        if @mode == :encrypt
          if tag
            result.value = @cryptor.encrypt("#{tag} #{value}")
            result.tag = nil
            result.plain = true
          else
            result.value = @cryptor.encrypt(value)
          end
          result.value = add_prefix_and_suffix(result.value)
        else
          value = remove_prefix_and_suffix(value)
          decrypted_value = @cryptor.decrypt(value).to_s
          if decrypted_value =~ /\A(!.*?)\s+(.*)\z/
            result.tag = $1
            result.plain = false
            result.value = $2
          else
            result.value = decrypted_value
          end
        end
      end

      @path_stack.pop

      result
    end

    def alias(anchor)
      unless @last.is_a?(YAML::Nodes::Sequence)
        @path_stack.pop
      end
      super
    end

    private

    def add_prefix_and_suffix(value)
      return "#{@prefix}#{value}#{@suffix}"
    end

    def remove_prefix_and_suffix(value)
      if @prefix != nil && value.start_with?(@prefix)
        value = value.delete_prefix(@prefix)
      end
      if @suffix != nil && value.end_with?(@suffix)
        value = value.delete_suffix(@suffix)
      end
      value
    end

    def match_path?
      @target_paths.any? do |target_path|
        target_path.each_with_index.all? do |path, i|
          if path == "*"
            true
          else
            if path.is_a?(Regexp)
              path.match(@path_stack[i])
            elsif path.is_a?(Symbol)
              path.inspect == @path_stack[i]
            else
              path == @path_stack[i]
            end
          end
        end
      end
    end
  end
end
