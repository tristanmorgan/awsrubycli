# frozen_string_literal: true

require 'aws-sdk-cloudformation'

require 'awscli_subcommand'

module Awscli
  # ec2 sub commands
  class Cloudformation < SubCommandBase
    map ['describe-stacks'] => :describe_stacks
    map ['delete-stack'] => :delete_stack

    desc 'describe-stacks [NAME]', 'get stacks with name'
    method_option :endpoint, type: :string, desc: 'Endpoint to connect to'
    # aws cloudformation describe-stacks name
    def describe_stacks(name = nil)
      options[:endpoint] ||= ENV.fetch('AWS_CLOUDFORMATION_ENDPOINT', nil)
      client = Aws::CloudFormation::Client.new(
        options[:endpoint] ? { endpoint: options[:endpoint] } : {}
      )
      resp = client.describe_stacks(
        { stack_name: name }
      )

      puts JSON.pretty_generate(resp.to_h)
    end

    desc 'delete-stack NAME', 'delete a stack with name'
    method_option :endpoint, type: :string, desc: 'Endpoint to connect to'
    # aws cloudformation delete-stack name
    def delete_stack(name)
      options[:endpoint] ||= ENV.fetch('AWS_CLOUDFORMATION_ENDPOINT', nil)
      client = Aws::CloudFormation::Client.new(
        options[:endpoint] ? { endpoint: options[:endpoint] } : {}
      )
      resp = client.delete_stack(
        { stack_name: name }
      )

      puts JSON.pretty_generate(resp.to_h)
    end
  end
end
