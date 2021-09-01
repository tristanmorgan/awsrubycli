# frozen_string_literal: true

require 'awscli_subcommand'

module Awscli
  # sts sub commands
  class Sts < SubCommandBase
    map ['get-caller-identity'] => :get_caller_identity

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
    end
  end
end
