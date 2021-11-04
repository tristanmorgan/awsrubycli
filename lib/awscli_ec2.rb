# frozen_string_literal: true

require 'aws-sdk-ec2'

require 'awscli_subcommand'

module Awscli
  # ec2 sub commands
  class Ec2 < SubCommandBase
    map ['describe-instances'] => :describe_instances
    map ['describe-images'] => :describe_images
    map ['describe-key-pairs'] => :describe_key_pairs
    map ['delete-key-pair'] => :delete_key_pair
    map ['get-windows-password'] => :get_windows_password

    desc 'describe-instances TAG', 'get instances with tag'
    method_option :endpoint, type: :string, desc: 'Endpoint to connect to'
    def describe_instances(tag)
      client = Aws::EC2::Client.new(options[:endpoint] ? { endpoint: options[:endpoint] } : {})
      resp = client.describe_instances(
        filters: [
          {
            name: 'tag:Name',
            values: [
              tag
            ]
          }
        ]
      )

      puts JSON.pretty_generate(resp.to_h)
    end

    desc 'describe-key-pairs', 'Describes all of your key pairs'
    method_option :endpoint, type: :string, desc: 'Endpoint to connect to'
    def describe_key_pairs
      client = Aws::EC2::Client.new(options[:endpoint] ? { endpoint: options[:endpoint] } : {})
      resp = client.describe_key_pairs

      puts JSON.pretty_generate(resp.to_h)
    end

    desc 'delete-key-pair', 'Deletes a key pair'
    method_option :endpoint, type: :string, desc: 'Endpoint to connect to'
    def delete_key_pair(name)
      client = Aws::EC2::Client.new(options[:endpoint] ? { endpoint: options[:endpoint] } : {})
      resp = client.delete_key_pair({ key_name: name })

      puts JSON.pretty_generate(resp.to_h)
    end

    desc 'describe-images TAG', 'describe images with tag'
    method_option :endpoint, type: :string, desc: 'Endpoint to connect to'
    def describe_images(tag)
      client = Aws::EC2::Client.new(options[:endpoint] ? { endpoint: options[:endpoint] } : {})
      resp = client.describe_images(
        filters: [
          {
            name: 'tag:Name',
            values: [
              tag
            ]
          }
        ]
      )

      puts JSON.pretty_generate(resp.to_h)
    end

    desc 'get-windows-password instance_id pem_path', 'Gets the windows password for an instance'
    method_option :endpoint, type: :string, desc: 'Endpoint to connect to'
    def get_windows_password(instance_id, pem_path)
      ec2 = Aws::EC2::Client.new(options[:endpoint] ? { endpoint: options[:endpoint] } : {})
      encrypted_password = ec2.get_password_data(instance_id: instance_id).password_data
      private_key = OpenSSL::PKey::RSA.new(File.read(pem_path))
      decoded = Base64.decode64(encrypted_password)
      password = private_key.private_decrypt(decoded)

      puts 'The password is...'
      puts password
    end
  end
end
