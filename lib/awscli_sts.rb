# frozen_string_literal: true

require 'aws-sdk-core'
require 'securerandom'

require 'awscli_subcommand'

module Awscli
  # sts sub commands
  class Sts < SubCommandBase
    map ['decode-authorization-message'] => :decode_authorization_message
    map ['get-caller-identity'] => :get_caller_identity
    map ['get-access-key-info'] => :get_access_key_info

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

    desc 'get-access-key-info', 'Get info about access keys'
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

    desc 'generate-fake-key', 'Generate fake keys for testing'
    # aws sts generate-fake-key
    def generate_fake_key
      resp = {
        access_key: {
          access_key_id: "AKIA#{Array.new(16) { [*'A'..'Z', *'2'..'7'].sample }.join}",
          create_date: Time.new,
          secret_access_key: SecureRandom.base64(30),
          status: 'Active',
          user_name: ENV.fetch('USER', 'awsrubycli')
        }
      }

      puts JSON.pretty_generate(resp.to_h)
    end
  end
end
