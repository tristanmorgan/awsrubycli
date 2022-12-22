# frozen_string_literal: true

require 'aws-sdk-kms'

require 'awscli_subcommand'

module Awscli
  # sts sub commands
  class Kms < SubCommandBase
    map ['list-keys'] => :list_keys
    map ['create-key'] => :create_key
    map ['delete-key'] => :delete_key

    desc 'list-keys', 'List KMS keys'
    method_option :endpoint, type: :string, desc: 'Endpoint to connect to'
    # aws kms list-keys
    def list_keys
      endpoint = ENV.fetch('AWS_KMS_ENDPOINT', options[:endpoint])
      client = Aws::KMS::Client.new(endpoint ? { endpoint: endpoint } : {})
      resp = client.list_keys(
        {}
      )

      puts JSON.pretty_generate(resp.to_h)
    end

    desc 'create-key', 'Create a KMS key'
    method_option :endpoint, type: :string, desc: 'Endpoint to connect to'
    # aws kms create-key
    def create_key
      endpoint = ENV.fetch('AWS_KMS_ENDPOINT', options[:endpoint])
      client = Aws::KMS::Client.new(endpoint ? { endpoint: endpoint } : {})
      resp = client.create_key(
        {}
      )

      puts JSON.pretty_generate(resp.to_h)
    end

    desc 'delete-key', 'Schedule a KMS key to delete'
    method_option :endpoint, type: :string, desc: 'Endpoint to connect to'
    # aws kms delete-key
    def delete_key(key_id, days)
      endpoint = ENV.fetch('AWS_KMS_ENDPOINT', options[:endpoint])
      client = Aws::KMS::Client.new(endpoint ? { endpoint: endpoint } : {})
      resp = client.schedule_key_deletion({
                                            key_id: key_id,
                                            pending_window_in_days: days
                                          })

      puts JSON.pretty_generate(resp.to_h)
    end
  end
end
