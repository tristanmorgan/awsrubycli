# frozen_string_literal: true

require 'aws-sdk-cloudformation'

require 'awscli_subcommand'

module Awscli
  # ec2 sub commands
  class Cloudformation < SubCommandBase
    desc 'describe-stacks [NAME]', 'get stacks with name'
    method_option :endpoint, type: :string, desc: 'Endpoint to connect to'
    # aws cloudformation describe-stacks name
    def describe_stacks(name = nil)
      endpoint = options[:endpoint]
      client = Aws::CloudFormation::Client.new(
        endpoint ? { endpoint: endpoint } : {}
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
      endpoint = options[:endpoint]
      client = Aws::CloudFormation::Client.new(
        endpoint ? { endpoint: endpoint } : {}
      )
      resp = client.delete_stack(
        { stack_name: name }
      )

      puts JSON.pretty_generate(resp.to_h)
    end
  end
end
