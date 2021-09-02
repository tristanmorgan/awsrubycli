# frozen_string_literal: true

require 'thor'
require 'json'

require 'awscli_ec2'
require 'awscli_iam'
require 'awscli_kms'
require 'awscli_s3'
require 'awscli_sts'

module Awscli
  # Adds subcommands to Thor super
  class Cli < Thor
    def self.exit_on_failure?
      true
    end

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
