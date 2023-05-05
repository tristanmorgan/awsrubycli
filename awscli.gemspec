# frozen_string_literal: true

lib = File.expand_path('lib', __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

Gem::Specification.new do |spec|
  spec.name          = 'awscli'
  spec.version       = '0.0.3'
  spec.authors       = ['Tristan Morgan']
  spec.email         = ['tristan@vibrato.com.au']

  spec.summary       = 'AWS cli in Ruby'
  spec.description   = 'AWS cli in Ruby'
  spec.homepage      = 'https://github.com/servian/awsrubycli'
  spec.license       = 'MIT'

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^spec/|^\..*|^.*\.png}) }
  spec.bindir        = 'exe'
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.required_ruby_version = '>= 2.6.0'

  spec.add_dependency('aws-sdk-cloudformation')
  spec.add_dependency('aws-sdk-ec2')
  spec.add_dependency('aws-sdk-iam')
  spec.add_dependency('aws-sdk-kms')
  spec.add_dependency('aws-sdk-s3')
  spec.add_dependency('thor')
  spec.metadata = {
    'rubygems_mfa_required' => 'true'
  }
end
