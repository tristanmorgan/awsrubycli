# frozen_string_literal: true

require 'aws-sdk-s3'

require 'awscli_subcommand'
require 'awscli/s3_helper'

module Awscli
  # s3 sub commands
  class S3 < SubCommandBase
    desc 'ls [SOURCE]', 'list buckets or object in SOURCE'
    method_option :endpoint, type: :string, desc: 'Endpoint to connect to'
    method_option :recursive, type: :boolean, desc: 'Recursivly list', default: false
    method_option :path_style, type: :boolean, desc: 'Force path style endpoint', default: false
    # aws s3 ls s3://teamvibrato/hashicorp/consul/
    def ls(source = nil) # rubocop:disable Metrics/AbcSize
      bucket, prefix = Awscli::S3Helper.bucket_from_string(source)
      clientops = {}
      clientops[:endpoint] = options[:endpoint] if options[:endpoint]
      clientops[:force_path_style] = options[:path_style] if options[:path_style]
      client = Aws::S3::Client.new(clientops)
      resp = if bucket
               list_objects(client, bucket, prefix, options[:recursive])
             else
               client.list_buckets({})
             end
      puts JSON.pretty_generate(resp.to_h)
    end

    desc 'pressign PATH', 'generate a presigned URL for PATH'
    method_option :endpoint, type: :string, desc: 'Endpoint to connect to'
    method_option :path_style, type: :boolean, desc: 'Force path style endpoint', default: false
    # aws s3 presign s3://teamvibrato/hashicorp/consul/
    def presign(path)
      bucket, key = Awscli::S3Helper.bucket_from_string(path)
      clientops = {}
      clientops[:endpoint] = options[:endpoint] if options[:endpoint]
      clientops[:force_path_style] = options[:path_style] if options[:path_style]
      signer = Aws::S3::Presigner.new(clientops)
      url = signer.presigned_url(:get_object, bucket: bucket, key: key)
      puts url
    end

    desc 'mb BUCKET', 'make a new BUCKET'
    method_option :endpoint, type: :string, desc: 'Endpoint to connect to'
    method_option :path_style, type: :boolean, desc: 'Force path style endpoint', default: false
    # aws s3 mb teamvibrato
    def mb(bucket)
      clientops = {}
      clientops[:endpoint] = options[:endpoint] if options[:endpoint]
      clientops[:force_path_style] = options[:path_style] if options[:path_style]
      client = Aws::S3::Client.new(clientops)
      unless Awscli::S3Helper.s3_path?("s3://#{bucket}/test")
        warn 'Bucket name not valid.'
        exit 1
      end
      resp = client.create_bucket(bucket: bucket)
      puts JSON.pretty_generate(resp.to_h)
    end

    desc 'cp SOURCE [PATH]', 'Copy from SOURCE to PATH'
    method_option :endpoint, type: :string, desc: 'Endpoint to connect to'
    method_option :path_style, type: :boolean, desc: 'Force path style endpoint', default: false
    # aws s3 cp s3://teamvibrato/hashicorp/consul/file.ext
    def cp(source, dest = nil)
      dest_bool = Awscli::S3Helper.s3_path?(dest)
      source_bool = Awscli::S3Helper.s3_path?(source)
      clientops = {}
      clientops[:endpoint] = options[:endpoint] if options[:endpoint]
      clientops[:force_path_style] = options[:path_style] if options[:path_style]
      client = Aws::S3::Client.new(clientops)
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
    method_option :path_style, type: :boolean, desc: 'Force path style endpoint', default: false
    # aws s3 rm s3://teamvibrato/hashicorp/consul/file.ext
    def rm(path)
      bucket, key = Awscli::S3Helper.bucket_from_string(path)
      clientops = {}
      clientops[:endpoint] = options[:endpoint] if options[:endpoint]
      clientops[:force_path_style] = options[:path_style] if options[:path_style]
      client = Aws::S3::Client.new(clientops)
      client.delete_object(
        {
          bucket: bucket,
          key: key
        }
      )
    end

    desc 'rb bucket', 'delete a bucket'
    method_option :endpoint, type: :string, desc: 'Endpoint to connect to'
    method_option :path_style, type: :boolean, desc: 'Force path style endpoint', default: false
    # aws s3 rb s3://teamvibrato/
    def rb(path)
      bucket, key = Awscli::S3Helper.bucket_from_string(path)
      unless key == ''
        warn 'Only specify a bucket.'
        exit 1
      end
      clientops = {}
      clientops[:endpoint] = options[:endpoint] if options[:endpoint]
      clientops[:force_path_style] = options[:path_style] if options[:path_style]
      client = Aws::S3::Client.new(clientops)
      begin
        client.delete_bucket(
          {
            bucket: bucket
          }
        )
      rescue Aws::S3::Errors::BucketNotEmpty => e
        warn e
        exit 1
      end
    end

    private

    def copy_to_s3(source, dest, client)
      bucket, key = Awscli::S3Helper.bucket_from_string(dest)
      key ||= File.basename(source)
      File.open(source, 'rb') do |file|
        content_md5 = [[Digest::MD5.file(source).hexdigest].pack('H*')].pack('m0')
        client.put_object(bucket: bucket, key: key, content_md5: content_md5, body: file)
      end
    end

    def copy_from_s3(source, dest, client)
      bucket, key = Awscli::S3Helper.bucket_from_string(source)
      dest ||= File.basename(key)
      dest = File.join(dest, File.basename(key)) if File.directory?(dest)
      client.get_object(response_target: dest, bucket: bucket, key: key)
    rescue Aws::S3::Errors::NoSuchKey => e
      warn e
      exit 1
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
    rescue Aws::S3::Errors::NoSuchKey => e
      warn e
      exit 1
    end

    def list_objects(client, bucket, prefix, recursive)
      client.list_objects_v2(
        bucket: bucket,
        prefix: prefix,
        delimiter: recursive ? nil : '/'
      )
    rescue Aws::S3::Errors::NoSuchBucket => e
      warn e
      exit 1
    end
  end
end
