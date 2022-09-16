# frozen_string_literal: true

require 'aws-sdk-iam'

require 'awscli_subcommand'

module Awscli
  # sts sub commands
  class Iam < SubCommandBase
    desc 'list-users', 'List users in account'
    method_option :endpoint, type: :string, desc: 'Endpoint to connect to'
    # aws iam list-users
    def list_users
      endpoint = ENV.fetch('AWS_IAM_ENDPOINT', options[:endpoint])
      client = Aws::IAM::Client.new(endpoint ? { endpoint: endpoint } : {})
      resp = client.list_users(
        {
        }
      )

      puts JSON.pretty_generate(resp.to_h)
    end

    desc 'list-access-keys', 'List access keys for User'
    method_option :endpoint, type: :string, desc: 'Endpoint to connect to'
    # aws iam list-access-keys
    def list_access_keys(user_name)
      endpoint = ENV.fetch('AWS_IAM_ENDPOINT', options[:endpoint])
      client = Aws::IAM::Client.new(endpoint ? { endpoint: endpoint } : {})
      resp = client.list_access_keys(
        {
          user_name: user_name
        }
      )

      puts JSON.pretty_generate(resp.to_h)
    end
  end
end
