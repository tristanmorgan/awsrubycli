# frozen_string_literal: true

require 'aws-sdk-ec2'
require 'aws-sdk-s3'
require 'thor'

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
    # aws sts get-caller-identity
    desc 'get-caller-identity', 'get-caller-identity'
    def get_caller_identity
      client = Aws::STS::Client.new
      resp = client.get_caller_identity(
        {
        }
      )

      puts resp.to_h.to_json
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

      puts resp.to_h.to_json
    end
  end

  class Ec2 < SubCommandBase
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

      puts resp.to_h.to_json
    end
  end

  class Cli < Thor
    desc 'ec2 SUBCOMMAND', 'run ec2 commands'
    subcommand 'ec2', Ec2

    desc 'sts SUBCOMMAND', 'run sts commands'
    subcommand 'sts', Sts

    desc 's3 SUBCOMMAND', 'run s3 commands'
    subcommand 's3', S3
  end
end
