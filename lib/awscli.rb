# frozen_string_literal: true

require 'aws-sdk-ec2'
require 'aws-sdk-s3'
require 'thor'
require 'json'

class SubCommandBase < Thor
  def self.banner(command, _namespace = nil, _subcommand = false)
    "#{basename} #{subcommand_prefix} #{command.usage}"
  end

  def self.subcommand_prefix
    name.gsub(/.*::/, '').gsub(/^[A-Z]/) { |match| match[0].downcase }.gsub(/[A-Z]/) { |match| "-#{match[0].downcase}" }
  end
end

module Awscli
  class Sts < SubCommandBase
    map ['get-caller-identity'] => :get_caller_identity

    # aws sts get-caller-identity
    desc 'get-caller-identity', 'get-caller-identity'
    def get_caller_identity
      client = Aws::STS::Client.new
      resp = client.get_caller_identity(
        {
        }
      )

      puts JSON.pretty_generate(resp.to_h)
    end
  end

  class S3 < SubCommandBase
    # aws s3 ls s3://teamvibrato/hashicorp/consul/
    desc 'ls BUCKET', 'list objects in a bucket'
    def ls(bucket)
      client = Aws::S3::Client.new
      resp = client.list_objects_v2(
        bucket: bucket
      )

      puts JSON.pretty_generate(resp.to_h)
    end

    desc 'pressign BUCKET KEY', 'generate a presigned URL for BUCKET and KEY'
    def presign(bucket, key)
      signer = Aws::S3::Presigner.new
      url = signer.presigned_url(:get_object, bucket: bucket, key: key)
      puts url
    end
  end

  class Ec2 < SubCommandBase
    map ['describe-instances'] => :describe_instances
    map ['describe-images'] => :describe_images
    map ['get-windows-password'] => :get_windows_password

    desc 'describe-instances TAG', 'get instances with tag'
    def describe_instances(tag)
      client = Aws::EC2::Client.new
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
    def describe_images(tag)
      client = Aws::EC2::Client.new
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
    def get_windows_password(instance_id, pem_path)
      ec2 = Aws::EC2::Client.new
      encrypted_password = ec2.get_password_data(instance_id: instance_id).password_data
      private_key = OpenSSL::PKey::RSA.new(File.read(pem_path))
      decoded = Base64.decode64(encrypted_password)
      password = private_key.private_decrypt(decoded)

      puts 'The password is...'
      puts password
    end
  end

  class Cli < Thor
    def self.exit_on_failure?
      true
    end

    desc 'ec2 SUBCOMMAND', 'run ec2 commands'
    subcommand 'ec2', Ec2

    desc 'sts SUBCOMMAND', 'run sts commands'
    subcommand 'sts', Sts

    desc 's3 SUBCOMMAND', 'run s3 commands'
    subcommand 's3', S3
  end
end
