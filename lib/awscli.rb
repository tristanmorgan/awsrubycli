# frozen_string_literal: true

require 'aws-sdk-ec2'
require 'aws-sdk-kms'
require 'aws-sdk-s3'
require 'thor'
require 'json'

# Subclassing Thor to allow sub commands.
class SubCommandBase < Thor
  def self.banner(command, _namespace = nil, _subcommand = false) # rubocop:disable Style/OptionalBooleanParameter
    "#{basename} #{subcommand_prefix} #{command.usage}"
  end

  def self.subcommand_prefix
    name.gsub(/.*::/, '').gsub(/^[A-Z]/) { |match| match[0].downcase }.gsub(/[A-Z]/) { |match| "-#{match[0].downcase}" }
  end
end

module Awscli
  # sts sub commands
  class Kms < SubCommandBase
    map ['list-keys'] => :list_keys
    map ['create-key'] => :create_key

    # aws kms list-keys
    desc 'list-keys', 'list-keys'
    method_option :endpoint, type: :string, desc: 'Endpoint to connect to'
    def list_keys
      client = Aws::KMS::Client.new(options[:endpoint] ? { endpoint: options[:endpoint] } : {})
      resp = client.list_keys(
        {
        }
      )

      puts JSON.pretty_generate(resp.to_h)
    end

    # aws kms create-key
    desc 'create-key', 'create-key'
    method_option :endpoint, type: :string, desc: 'Endpoint to connect to'
    def create_key
      client = Aws::KMS::Client.new(options[:endpoint] ? { endpoint: options[:endpoint] } : {})
      resp = client.create_key(
        {
        }
      )

      puts JSON.pretty_generate(resp.to_h)
    end
  end

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

  # s3 sub commands
  class S3 < SubCommandBase
    # aws s3 ls s3://teamvibrato/hashicorp/consul/
    desc 'ls BUCKET [PREFIX]', 'list objects in a bucket'
    method_option :endpoint, type: :string, desc: 'Endpoint to connect to'
    def ls(bucket, prefix = nil)
      client = Aws::S3::Client.new(options[:endpoint] ? { endpoint: options[:endpoint] } : {})
      resp = if prefix
               client.list_objects_v2(
                 bucket: bucket,
                 prefix: prefix
               )
             else
               client.list_objects_v2(
                 bucket: bucket
               )
             end

      puts JSON.pretty_generate(resp.to_h)
    end

    desc 'pressign BUCKET KEY', 'generate a presigned URL for BUCKET and KEY'
    method_option :endpoint, type: :string, desc: 'Endpoint to connect to'
    def presign(bucket, key)
      signer = Aws::S3::Presigner.new(options[:endpoint] ? { endpoint: options[:endpoint] } : {})
      url = signer.presigned_url(:get_object, bucket: bucket, key: key)
      puts url
    end

    desc 'download BUCKET KEY PATH', 'Download to a PATH for BUCKET and KEY'
    method_option :endpoint, type: :string, desc: 'Endpoint to connect to'
    def download(bucket, key, path)
      client = Aws::S3::Client.new(options[:endpoint] ? { endpoint: options[:endpoint] } : {})
      File.open(path, 'wb') do |file|
        client.get_object(bucket: bucket, key: key) do |chunk|
          file.write(chunk)
        end
      end
    end
  end

  # ec2 sub commands
  class Ec2 < SubCommandBase
    map ['describe-instances'] => :describe_instances
    map ['describe-images'] => :describe_images
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

  # Adds subcommands to Thor super
  class Cli < Thor
    def self.exit_on_failure?
      true
    end

    desc 'ec2 SUBCOMMAND', 'run ec2 commands'
    subcommand 'ec2', Ec2

    desc 'kms SUBCOMMAND', 'run kms commands'
    subcommand 'kms', Kms

    desc 'sts SUBCOMMAND', 'run sts commands'
    subcommand 'sts', Sts

    desc 's3 SUBCOMMAND', 'run s3 commands'
    subcommand 's3', S3
  end
end
