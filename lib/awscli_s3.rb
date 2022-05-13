# frozen_string_literal: true

require 'aws-sdk-s3'

require 'awscli_subcommand'

module Awscli
  # s3 sub commands
  class S3 < SubCommandBase
    # aws s3 ls s3://teamvibrato/hashicorp/consul/
    desc 'ls BUCKET [PREFIX]', 'list objects in a bucket'
    method_option :endpoint, type: :string, desc: 'Endpoint to connect to'
    def ls(bucket = nil, prefix = nil)
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

    desc 'pressign BUCKET KEY', 'generate a presigned URL for BUCKET and KEY'
    method_option :endpoint, type: :string, desc: 'Endpoint to connect to'
    def presign(bucket, key)
      clientops = { endpoint: options[:endpoint], force_path_style: true }
      signer = Aws::S3::Presigner.new(options[:endpoint] ? clientops : {})
      url = signer.presigned_url(:get_object, bucket: bucket, key: key)
      puts url
    end

    desc 'download BUCKET KEY PATH', 'Download to a PATH for BUCKET and KEY'
    method_option :endpoint, type: :string, desc: 'Endpoint to connect to'
    def download(bucket, key, path = nil)
      clientops = { endpoint: options[:endpoint], force_path_style: true }
      client = Aws::S3::Client.new(options[:endpoint] ? clientops : {})
      path ||= File.basename(key)
      File.open(path, 'wb') do |file|
        client.get_object(bucket: bucket, key: key) do |chunk|
          file.write(chunk)
        end
      end
    end

    desc 'upload PATH BUCKET KEY', 'Upload from a PATH to a BUCKET and KEY'
    method_option :endpoint, type: :string, desc: 'Endpoint to connect to'
    def upload(path, bucket, key = nil)
      clientops = { endpoint: options[:endpoint], force_path_style: true }
      client = Aws::S3::Client.new(options[:endpoint] ? clientops : {})
      key ||= File.basename(path)
      File.open(path, 'rb') do |file|
        client.put_object(bucket: bucket, key: key, body: file)
      end
    end
  end
end
