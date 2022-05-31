# frozen_string_literal: true

require 'aws-sdk-s3'

require 'awscli_subcommand'
require 'awscli/s3_helper'

module Awscli
  # s3 sub commands
  class S3 < SubCommandBase
    # aws s3 ls s3://teamvibrato/hashicorp/consul/
    desc 'ls [SOURCE]', 'list buckets or object in SOURCE'
    method_option :endpoint, type: :string, desc: 'Endpoint to connect to'
    def ls(source = nil)
      bucket, prefix = Awscli::S3Helper.bucket_from_string(source)
      clientops = { endpoint: options[:endpoint], force_path_style: true }
      client = Aws::S3::Client.new(options[:endpoint] ? clientops : {})
      resp = if prefix
               client.list_objects_v2(
                 bucket: bucket,
                 prefix: prefix
               )
             elsif bucket
               client.list_objects_v2(
                 bucket: bucket
               )
             else
               client.list_buckets({})
             end

      puts JSON.pretty_generate(resp.to_h)
    end

    desc 'pressign PATH', 'generate a presigned URL for PATH'
    method_option :endpoint, type: :string, desc: 'Endpoint to connect to'
    def presign(path)
      bucket, key = Awscli::S3Helper.bucket_from_string(path)
      clientops = { endpoint: options[:endpoint], force_path_style: true }
      signer = Aws::S3::Presigner.new(options[:endpoint] ? clientops : {})
      url = signer.presigned_url(:get_object, bucket: bucket, key: key)
      puts url
    end

    desc 'cp SOURCE [PATH]', 'Download from SOURCE to PATH'
    method_option :endpoint, type: :string, desc: 'Endpoint to connect to'
    def cp(source, path = nil)
      bucket, key = Awscli::S3Helper.bucket_from_string(source)
      path ||= File.basename(key)
      clientops = { endpoint: options[:endpoint], force_path_style: true }
      client = Aws::S3::Client.new(options[:endpoint] ? clientops : {})
      File.open(path, 'wb') do |file|
        client.get_object(bucket: bucket, key: key) do |chunk|
          file.write(chunk)
        end
      end
    end

    desc 'upload PATH DEST', 'Upload from a PATH to a DEST'
    method_option :endpoint, type: :string, desc: 'Endpoint to connect to'
    def upload(path, dest)
      bucket, key = Awscli::S3Helper.bucket_from_string(dest)
      clientops = { endpoint: options[:endpoint], force_path_style: true }
      client = Aws::S3::Client.new(options[:endpoint] ? clientops : {})
      key ||= File.basename(path)
      File.open(path, 'rb') do |file|
        client.put_object(bucket: bucket, key: key, body: file)
      end
    end
  end
end
