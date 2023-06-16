# frozen_string_literal: true

require 'thor'
require 'json'

require 'awscli_cloudformation'
require 'awscli_dynamodb'
require 'awscli_ec2'
require 'awscli_iam'
require 'awscli_kms'
require 'awscli_s3'
require 'awscli_sts'

module Awscli
  # Adds subcommands to Thor super
  class Cli < Thor
    package_name 'Aws'
    def self.exit_on_failure?
      true
    end

    map %w[--version -v] => :__version
    desc '--version, -v', 'print the version number'
    # print the version number
    def __version
      puts 'aws(ruby)cli v0.0.3'
      puts "aws-sdk-core v#{Aws::CORE_GEM_VERSION}"
      puts 'Homepage https://github.com/tristanmorgan/awsrubycli'
    end

    desc 'cloudformation SUBCOMMAND', 'run cloudformation commands'
    subcommand 'cloudformation', Cloudformation

    desc 'dynamodb SUBCOMMAND', 'run dynamodb commands'
    subcommand 'dynamodb', Dynamodb

    desc 'ec2 SUBCOMMAND', 'run ec2 commands'
    subcommand 'ec2', Ec2

    desc 'iam SUBCOMMAND', 'run iam commands'
    subcommand 'iam', Iam

    desc 'kms SUBCOMMAND', 'run kms commands'
    subcommand 'kms', Kms

    desc 'sts SUBCOMMAND', 'run sts commands'
    subcommand 'sts', Sts

    desc 's3 SUBCOMMAND', 'run s3 commands'
    subcommand 's3', S3
  end
end
