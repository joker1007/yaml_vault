require 'strscan'

module YamlVault
  class KeyParser
    class InvalidPathFormat < StandardError; end

    def self.parse(str)
      new.parse(str)
    end

    def parse(str)
      s = StringScanner.new(str)
      path = []
      until s.eos?
        if token = s.scan(/'(.*?)'/)
          path << s[1]
        elsif token = s.scan(/"(.*?)"/)
          path << s[1]
        elsif token = s.scan(%r{/(.*?)/})
          path << Regexp.new(s[1])
        elsif token = s.scan(/\[(\d+)\]/)
          path << s[1].to_i
        elsif token = s.scan(/:([^\.]+)/)
          path << s[1].to_sym
        elsif token = s.scan(/\./)
          # noop
        elsif token = s.scan(/[^\.]*/)
          path << token
        end
      end

      raise InvalidPathFormat.new("`$` must be at first") unless path.first == "$"

      path
    end
  end
end
