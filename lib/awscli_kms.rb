# frozen_string_literal: true

require 'awscli_subcommand'

module Awscli
  # sts sub commands
  class Kms < SubCommandBase
    map ['list-keys'] => :list_keys
    map ['create-key'] => :create_key

    # aws kms list-keys
    desc 'list-keys', 'list-keys'
    method_option :endpoint, type: :string, desc: 'Endpoint to connect to'
    def list_keys
      client = Aws::KMS::Client.new(options[:endpoint] ? { endpoint: options[:endpoint] } : {})
      resp = client.list_keys(
        {
        }
      )

      puts JSON.pretty_generate(resp.to_h)
    end

    # aws kms create-key
    desc 'create-key', 'create-key'
    method_option :endpoint, type: :string, desc: 'Endpoint to connect to'
    def create_key
      client = Aws::KMS::Client.new(options[:endpoint] ? { endpoint: options[:endpoint] } : {})
      resp = client.create_key(
        {
        }
      )

      puts JSON.pretty_generate(resp.to_h)
    end
  end
end
