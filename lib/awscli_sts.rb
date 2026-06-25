# frozen_string_literal: true

require 'aws-sdk-core'

require 'awscli_subcommand'

module Awscli
  # sts sub commands
  class Sts < SubCommandBase
    desc 'decode-authorization-message MESSAGE', 'Decode an authorization MESSAGE'
    method_option :endpoint, type: :string, desc: 'Endpoint to connect to'
    # aws sts decode-authorization-message MESSAGE
    def decode_authorization_message(encoded_message)
      endpoint = options[:endpoint]
      client = Aws::STS::Client.new(endpoint ? { endpoint: endpoint } : {})
      resp = client.decode_authorization_message(
        { encoded_message: encoded_message }
      )

      puts JSON.pretty_generate(resp.to_h)
    rescue Aws::STS::Errors::ServiceError => e
      warn e.message
      exit 1
    end

    desc 'get-caller-identity', 'Get current users details'
    method_option :endpoint, type: :string, desc: 'Endpoint to connect to'
    # aws sts get-caller-identity
    def get_caller_identity
      endpoint = options[:endpoint]
      client = Aws::STS::Client.new(endpoint ? { endpoint: endpoint } : {})
      resp = client.get_caller_identity(
        {}
      )

      puts JSON.pretty_generate(resp.to_h)
    rescue Aws::STS::Errors::ServiceError => e
      warn e.message
      exit 1
    end

    desc 'get-access-key-info ACCESS_KEY', 'Get info about access keys'
    method_option :endpoint, type: :string, desc: 'Endpoint to connect to'
    # aws sts get-access-key-info
    def get_access_key_info(key)
      endpoint = options[:endpoint]
      client = Aws::STS::Client.new(endpoint ? { endpoint: endpoint } : {})
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

    desc 'get-token', 'Get a session token'
    method_option :endpoint, type: :string, desc: 'Endpoint to connect to'
    method_option :name, type: :string, desc: 'name of federated user'
    method_option :code, type: :string, desc: 'mfa code'
    method_option :role_arn, type: :string, desc: 'ARN of policy to use'
    method_option :mfa_arn, type: :string, desc: 'ARN of mfa to use'
    method_option :duration, type: :numeric, desc: 'duration in seconds'
    # get-token
    def get_token # rubocop:disable Metrics/MethodLength, Metrics/AbcSize
      endpoint = options[:endpoint]
      client = Aws::STS::Client.new(endpoint ? { endpoint: endpoint } : {})

      resp =
        if options[:role_arn]
          client.assume_role(
            duration_seconds: options[:duration].to_i,
            role_arn: options[:role_arn],
            role_session_name: options[:name]
          )
        elsif options[:code]
          client.get_session_token(
            duration_seconds: options[:duration].to_i,
            serial_number: options[:mfa_arn],
            token_code: options[:code]
          )
        else
          client.get_federation_token(
            name: options[:name],
            policy: ADMIN_POLICY,
            duration_seconds: options[:duration]
          )
        end

      puts JSON.pretty_generate(resp.to_h)
    rescue Aws::STS::Errors::ServiceError => e
      warn e.message
      exit 1
    end

    desc 'passcheck PASSWORD', 'check a password'
    # aws sts passcheck PASSWORD
    def passcheck(password = nil)
      password ||= Thor::LineEditor.readline('Enter test password: ', echo: false).strip
      sha1 = OpenSSL::Digest.new('SHA1')
      digest = sha1.digest(password).unpack1('H*').upcase

      uri       = URI("https://api.pwnedpasswords.com/range/#{digest[0..4]}")
      request   = Net::HTTP.new(uri.host, uri.port)
      request.use_ssl = true
      returned_content = request.get(uri).body

      raise 'insecure password' if returned_content.include?(digest[5..])

      puts 'Password does not appear in a leak.'
    end
  end
end
