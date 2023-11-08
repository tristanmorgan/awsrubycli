# frozen_string_literal: true

require 'aws-sdk-dynamodb'

require 'awscli_subcommand'

module Awscli
  # sts sub commands
  class Dynamodb < SubCommandBase
    desc 'list-tables', 'List tables in account'
    method_option :endpoint, type: :string, desc: 'Endpoint to connect to'
    # aws dynamodb list-tables
    def list_tables
      endpoint = options[:endpoint]
      client = Aws::DynamoDB::Client.new(endpoint ? { endpoint: endpoint } : {})
      resp = client.list_tables(
        {}
      )

      puts JSON.pretty_generate(resp.to_h)
    end

    desc 'describe-table', 'describe a table'
    method_option :endpoint, type: :string, desc: 'Endpoint to connect to'
    # aws dynamodb describe-table
    def describe_table(table_name)
      endpoint = options[:endpoint]
      client = Aws::DynamoDB::Client.new(endpoint ? { endpoint: endpoint } : {})
      resp = client.describe_table(
        {
          table_name: table_name
        }
      )

      puts JSON.pretty_generate(resp.to_h)
    rescue Aws::DynamoDB::Errors::ResourceNotFoundException => e
      warn e.message
      exit 1
    end

    desc 'delete-table', 'delete a table'
    method_option :endpoint, type: :string, desc: 'Endpoint to connect to'
    # aws dynamodb delete-table
    def delete_table(table_name)
      endpoint = options[:endpoint]
      client = Aws::DynamoDB::Client.new(endpoint ? { endpoint: endpoint } : {})
      resp = client.delete_table(
        {
          table_name: table_name
        }
      )

      puts JSON.pretty_generate(resp.to_h)
    rescue Aws::DynamoDB::Errors::ResourceNotFoundException => e
      warn e.message
      exit 1
    end
  end
end
