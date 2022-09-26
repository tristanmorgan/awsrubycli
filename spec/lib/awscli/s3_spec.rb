# frozen_string_literal: true

require 'spec_helper'
require 'thor'
require_relative '../../../lib/awscli_s3'

describe Awscli::S3 do
  context 'when credentials available' do
    let(:s3_client) { instance_double(Aws::S3::Client) }

    before do
      allow(Aws::S3::Client).to receive(:new).and_return(s3_client)
      allow(s3_client).to receive(:list_buckets).and_return(
        {
          buckets: [
            {
              name: 'distribution',
              creation_date: '2016-07-08 06:33:33 UTC'
            }
          ],
          owner: {
            display_name: 'minio',
            id: '02d6176db174dc93cb1b899f7c6078f08654445fe8cf1b6ce98d8855f66bdbf4'
          }
        }
      )
      allow(s3_client).to receive(:list_objects_v2).and_return(
        {
          is_truncated: false,
          name: 'distribution',
          prefix: '',
          delimiter: '/',
          max_keys: 1000,
          common_prefixes: [
            {
              prefix: 'homebridge/'
            },
            {
              prefix: 'linux/'
            },
            {
              prefix: 'minecraft/'
            },
            {
              prefix: 'terraform/'
            }
          ],
          key_count: 4
        }
      )
    end

    it 'calls ls' do
      expect { described_class.start(%w[ls]) }
        .to output(/buckets/).to_stdout
    end

    it 'calls ls s3://distribution' do
      expect { described_class.start(%w[ls s3://distribution]) }
        .to output(/common_prefixes/).to_stdout
    end
  end
end
