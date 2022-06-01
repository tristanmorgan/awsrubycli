# frozen_string_literal: true

require 'aws-sdk-iam'

require 'awscli_subcommand'

module Awscli
  # sts sub commands
  class Iam < SubCommandBase
    desc 'list-users', 'list-users'
    method_option :endpoint, type: :string, desc: 'Endpoint to connect to'
    # aws iam list-users
    def list_users
      client = Aws::IAM::Client.new(options[:endpoint] ? { endpoint: options[:endpoint] } : {})
      resp = client.list_users(
        {
        }
      )

      puts JSON.pretty_generate(resp.to_h)
    end

    desc 'list-access-keys', 'list-access-keys'
    method_option :endpoint, type: :string, desc: 'Endpoint to connect to'
    # aws iam list-access-keys
    def list_access_keys(user_name)
      client = Aws::IAM::Client.new(options[:endpoint] ? { endpoint: options[:endpoint] } : {})
      resp = client.list_access_keys(
        {
          user_name: user_name
        }
      )

      puts JSON.pretty_generate(resp.to_h)
    end
  end
end
