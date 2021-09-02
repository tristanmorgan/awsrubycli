# frozen_string_literal: true

require 'aws-sdk-s3'

require 'awscli_subcommand'

module Awscli
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
end
