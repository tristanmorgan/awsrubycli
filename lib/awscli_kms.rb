# frozen_string_literal: true

require 'aws-sdk-kms'

require 'awscli_subcommand'

module Awscli
  # sts sub commands
  class Kms < SubCommandBase
    map ['list-keys'] => :list_keys
    map ['create-key'] => :create_key

    desc 'list-keys', 'list-keys'
    method_option :endpoint, type: :string, desc: 'Endpoint to connect to'
    # aws kms list-keys
    def list_keys
      options[:endpoint] ||= ENV.fetch('AWS_KMS_ENDPOINT', nil)
      client = Aws::KMS::Client.new(options[:endpoint] ? { endpoint: options[:endpoint] } : {})
      resp = client.list_keys(
        {
        }
      )

      puts JSON.pretty_generate(resp.to_h)
    end

    desc 'create-key', 'create-key'
    method_option :endpoint, type: :string, desc: 'Endpoint to connect to'
    # aws kms create-key
    def create_key
      options[:endpoint] ||= ENV.fetch('AWS_KMS_ENDPOINT', nil)
      client = Aws::KMS::Client.new(options[:endpoint] ? { endpoint: options[:endpoint] } : {})
      resp = client.create_key(
        {
        }
      )

      puts JSON.pretty_generate(resp.to_h)
    end
  end
end
