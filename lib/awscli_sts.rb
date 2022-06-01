# frozen_string_literal: true

require 'awscli_subcommand'

module Awscli
  # sts sub commands
  class Sts < SubCommandBase
    map ['get-caller-identity'] => :get_caller_identity
    map ['get-access-key-info'] => :get_access_key_info

    desc 'get-caller-identity', 'get-caller-identity'
    method_option :endpoint, type: :string, desc: 'Endpoint to connect to'
    # aws sts get-caller-identity
    def get_caller_identity
      client = Aws::STS::Client.new(options[:endpoint] ? { endpoint: options[:endpoint] } : {})
      resp = client.get_caller_identity(
        {
        }
      )

      puts JSON.pretty_generate(resp.to_h)
    rescue Aws::STS::Errors::ServiceError => e
      warn e.message
      exit 1
    end

    desc 'get-access-key-info', 'get-caller-identity'
    method_option :endpoint, type: :string, desc: 'Endpoint to connect to'
    # aws sts get-access-key-info
    def get_access_key_info(key)
      client = Aws::STS::Client.new(options[:endpoint] ? { endpoint: options[:endpoint] } : {})
      resp = client.get_access_key_info(
        {
          access_key_id: key # required
        }
      )

      puts JSON.pretty_generate(resp.to_h)
    rescue Aws::STS::Errors::ServiceError => e
      warn e.message
      exit 1
    end
  end
end
