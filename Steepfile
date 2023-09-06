D = Steep::Diagnostic

target :lib do
  signature "sig"

  check "lib"                       # Directory name

  library "yaml"
  library "base64"

  # configure_code_diagnostics(D::Ruby.default)      # `default` diagnostics setting (applies by default)
  # configure_code_diagnostics(D::Ruby.strict)       # `strict` diagnostics setting
  # configure_code_diagnostics(D::Ruby.lenient)      # `lenient` diagnostics setting
  # configure_code_diagnostics(D::Ruby.silent)       # `silent` diagnostics setting
  configure_code_diagnostics do |hash|
    hash[D::Ruby::MethodDefinitionMissing] = :warning
    hash[D::Ruby::UnknownConstant] = nil
  end
end

target :test do
  # signature "sig", "sig-private"

  # check "test"

  # library "pathname"              # Standard libraries
end
