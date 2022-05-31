# frozen_string_literal: true

require 'awscli_subcommand'

module Awscli
  # sts sub commands
  class Sts < SubCommandBase
    map ['get-caller-identity'] => :get_caller_identity
    map ['get-access-key-info'] => :get_access_key_info

    # aws sts get-caller-identity
    desc 'get-caller-identity', 'get-caller-identity'
    method_option :endpoint, type: :string, desc: 'Endpoint to connect to'
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

    # aws sts get-access-key-info
    desc 'get-access-key-info', 'get-caller-identity'
    method_option :endpoint, type: :string, desc: 'Endpoint to connect to'
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
