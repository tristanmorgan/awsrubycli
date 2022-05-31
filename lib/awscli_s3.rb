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

    desc 'cp SOURCE [PATH]', 'Copy from SOURCE to PATH'
    method_option :endpoint, type: :string, desc: 'Endpoint to connect to'
    def cp(source, dest = nil)
      dest_bool = Awscli::S3Helper.s3_path?(dest)
      source_bool = Awscli::S3Helper.s3_path?(source)
      clientops = { endpoint: options[:endpoint], force_path_style: true }
      client = Aws::S3::Client.new(options[:endpoint] ? clientops : {})
      if dest_bool && source_bool
        copy_s3_to_s3(source, dest, client)
      elsif dest_bool
        copy_to_s3(source, dest, client)
      elsif source_bool
        copy_from_s3(source, dest, client)
      else
        warn 'UNIMPLEMENTED: both source and dest are local paths'
      end
    end

    desc 'rm PATH', 'delete a PATH'
    method_option :endpoint, type: :string, desc: 'Endpoint to connect to'
    def rm(path)
      bucket, key = Awscli::S3Helper.bucket_from_string(path)
      clientops = { endpoint: options[:endpoint], force_path_style: true }
      client = Aws::S3::Client.new(options[:endpoint] ? clientops : {})
      client.delete_object(
        {
          bucket: bucket,
          key: key
        }
      )
    end

    private

    def copy_to_s3(source, dest, client)
      bucket, key = Awscli::S3Helper.bucket_from_string(dest)
      key ||= File.basename(source)
      File.open(source, 'rb') do |file|
        client.put_object(bucket: bucket, key: key, body: file)
      end
    end

    def copy_from_s3(source, dest, client)
      bucket, key = Awscli::S3Helper.bucket_from_string(source)
      dest ||= File.basename(key)
      File.open(dest, 'wb') do |file|
        client.get_object(bucket: bucket, key: key) do |chunk|
          file.write(chunk)
        end
      end
    end

    def copy_s3_to_s3(source, dest, client)
      dbucket, dkey = Awscli::S3Helper.bucket_from_string(dest)
      sbucket, skey = Awscli::S3Helper.bucket_from_string(source)
      client.copy_object(
        {
          copy_source: "/#{sbucket}/#{skey}",
          bucket: dbucket,
          key: dkey
        }
      )
    end
  end
end
