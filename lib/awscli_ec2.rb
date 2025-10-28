# frozen_string_literal: true

require 'aws-sdk-ec2'

require 'awscli_subcommand'

module Awscli
  # ec2 sub commands
  class Ec2 < SubCommandBase
    desc 'create-key-pair NAME', 'create a new key-pair'
    method_option :endpoint, type: :string, desc: 'Endpoint to connect to'
    # aws ec2 create-key-pair name
    def create_key_pair(name)
      endpoint = options[:endpoint]
      client = Aws::EC2::Client.new(endpoint ? { endpoint: endpoint } : {})
      resp = client.create_key_pair({
                                      key_name: name
                                    })

      File.new("#{name}-key.pem", 'w').write resp.key_material
      resp.key_material = nil
      puts JSON.pretty_generate(resp.to_h)
    end

    desc 'describe-instances TAG', 'get instances with tag'
    method_option :endpoint, type: :string, desc: 'Endpoint to connect to'
    # aws ec2 describe-instances (with a tag)
    def describe_instances(tag = nil)
      endpoint = options[:endpoint]
      client = Aws::EC2::Client.new(endpoint ? { endpoint: endpoint } : {})
      filter = if tag.nil?
                 {}
               else
                 { filters: [
                   {
                     name: 'tag:Name',
                     values: [
                       tag
                     ]
                   }
                 ] }
               end
      resp = client.describe_instances(
        filter
      )

      puts JSON.pretty_generate(resp.to_h)
    end

    desc 'describe-instances TAG', 'get_console_output from and instance'
    method_option :endpoint, type: :string, desc: 'Endpoint to connect to'
    # aws ec2 get-console-output
    def get_console_output(instance)
      require 'base64'
      endpoint = options[:endpoint]
      client = Aws::EC2::Client.new(endpoint ? { endpoint: endpoint } : {})
      resp = client.get_console_output(
        {
          instance_id: instance
        }
      )

      puts Base64.decode64(resp.output)
    end

    desc 'describe-key-pairs', 'Describes all of your key pairs'
    method_option :endpoint, type: :string, desc: 'Endpoint to connect to'
    # aws ec2 describe-key-pairs
    def describe_key_pairs
      endpoint = options[:endpoint]
      client = Aws::EC2::Client.new(endpoint ? { endpoint: endpoint } : {})
      resp = client.describe_key_pairs

      puts JSON.pretty_generate(resp.to_h)
    end

    desc 'describe-subnetss', 'Describes subnets`s'
    method_option :endpoint, type: :string, desc: 'Endpoint to connect to'
    # aws ec2 describe-subnets
    def describe_subnets
      endpoint = options[:endpoint]
      client = Aws::EC2::Client.new(endpoint ? { endpoint: endpoint } : {})
      resp = client.describe_subnets

      puts JSON.pretty_generate(resp.to_h)
    end

    desc 'delete-key-pair', 'Deletes a key pair'
    method_option :endpoint, type: :string, desc: 'Endpoint to connect to'
    # aws ec2 delete-key-pair
    def delete_key_pair(name)
      endpoint = options[:endpoint]
      client = Aws::EC2::Client.new(endpoint ? { endpoint: endpoint } : {})
      resp = client.delete_key_pair({ key_name: name })

      puts JSON.pretty_generate(resp.to_h)
    end

    desc 'describe-images TAG', 'describe images with tag'
    method_option :endpoint, type: :string, desc: 'Endpoint to connect to'
    # aws ec2 describe-images
    def describe_images(tag)
      endpoint = options[:endpoint]
      client = Aws::EC2::Client.new(endpoint ? { endpoint: endpoint } : {})
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
    # aws ec2 get-windows-password
    def get_windows_password(instance_id, pem_path)
      endpoint = options[:endpoint]
      ec2 = Aws::EC2::Client.new(endpoint ? { endpoint: endpoint } : {})
      encrypted_password = ec2.get_password_data(instance_id: instance_id).password_data
      private_key = OpenSSL::PKey::RSA.new(File.read(pem_path))
      decoded = Base64.decode64(encrypted_password)
      password = private_key.private_decrypt(decoded)

      puts 'The password is...'
      puts password
    end
  end
end
