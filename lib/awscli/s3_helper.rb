# frozen_string_literal: true

# Awskeyring Module,
module Awscli
  # Input methods for Awskeyring
  module S3Helper
    # separate the bucket from the key.
    # s3://teamvibrato/hashicorp/consul/consul_linux.zip
    #
    # @param s3_path the combined s3 path
    # @return [Hash] with the new credentials
    #    bucket The bucket name
    #    key The path/key in the bucket
    def self.bucket_from_string(s3_path)
      return [nil, nil] if s3_path.nil?

      matchdata = %r{s3://(?<bucket>\w*)/?(?<key>.*)}.match(s3_path)
      [matchdata[:bucket], matchdata[:key]]
    end

    # Test if the path looks like an s3 path.
    #
    # @param s3_path The path to test
    # @return boolean if it matches
    def self.s3_path?(s3_path)
      %r{s3://\w*/\S*}.match?(s3_path)
    end
  end
end
