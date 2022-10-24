# frozen_string_literal: true

require 'spec_helper'
require 'thor'
require 'json'
require_relative '../../../lib/awscli_s3'

describe Awscli::S3 do
  context 'when testing list actions' do
    let(:s3_client) { instance_double(Aws::S3::Client) }
    let(:bucket_list) do
      {
        buckets: [
          {
            name: 'distribution',
            creation_date: '2016-07-08 06:33:33 UTC'
          }
        ],
        owner: {
          display_name: 'minio',
          id: '02d6176db174dc93cb1b899f7c6078f'
        }
      }
    end
    let(:folder_list) do
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
    end
    let(:file_list) do
      {
        is_truncated: false,
        contents: [
          {
            key: 'linux/dragonfly',
            last_modified: '2016-07-08 06:55:51 UTC',
            etag: '"1401712bc4a19b0188fc9ce4e1b6d159"',
            size: 16_842_752,
            storage_class: 'STANDARD',
            owner: {
              display_name: 'minio',
              id: '02d6176db174dc93cb1b899f7c6078f08654445fe8cf1b6ce98d8855f66bdbf4'
            }
          },
          {
            key: 'linux/duckdns',
            last_modified: '2016-07-08 06:53:38 UTC',
            etag: '"d9530c26f4d78d582c3d6deb5bcc83f1"',
            size: 4_915_200,
            storage_class: 'STANDARD',
            owner: {
              display_name: 'minio',
              id: '02d6176db174dc93cb1b899f7c6078f08654445fe8cf1b6ce98d8855f66bdbf4'
            }
          }
        ],
        name: 'distribution',
        prefix: 'linux/d',
        delimiter: '/',
        max_keys: 1000,
        key_count: 2
      }
    end

    before do
      allow(Aws::S3::Client).to receive(:new).and_return(s3_client)
      allow(s3_client).to receive(:list_buckets).and_return(bucket_list)
      allow(s3_client).to receive(:list_objects_v2).and_return(folder_list)
      allow(s3_client).to receive(:list_objects_v2)
        .with(bucket: 'distribution', prefix: 'linux/d', delimiter: '/')
        .and_return(file_list)
    end

    it 'calls ls' do
      expect { described_class.start(%w[ls]) }
        .to output("#{JSON.pretty_generate(bucket_list)}\n").to_stdout
    end

    it 'calls ls s3://distribution/' do
      expect { described_class.start(%w[ls s3://distribution]) }
        .to output("#{JSON.pretty_generate(folder_list)}\n").to_stdout
    end

    it 'calls ls s3://distribution/linux/d' do
      expect { described_class.start(%w[ls s3://distribution/linux/d]) }
        .to output("#{JSON.pretty_generate(file_list)}\n").to_stdout
    end
  end

  context 'when testing delete actions' do
    let(:s3_client) { instance_double(Aws::S3::Client) }

    before do
      allow(Aws::S3::Client).to receive(:new).and_return(s3_client)
      allow(s3_client).to receive(:delete_bucket).and_return({})
      allow(s3_client).to receive(:delete_object).and_return({})
    end

    it 'calls rm s3://delbucket/delobject' do
      described_class.start(%w[rm s3://delbucket/delobject])
      expect(s3_client).to have_received(:delete_object).with({ bucket: 'delbucket', key: 'delobject' })
    end

    it 'calls rb s3://delbucket' do
      described_class.start(%w[rb s3://delbucket])
      expect(s3_client).to have_received(:delete_bucket).with({ bucket: 'delbucket' })
    end
  end

  context 'when testing create bucket' do
    let(:s3_client) { instance_double(Aws::S3::Client) }

    before do
      allow(Aws::S3::Client).to receive(:new).and_return(s3_client)
      allow(s3_client).to receive(:create_bucket).and_return({ location: '/newbucket' })
    end

    it 'calls mb newbucket' do
      expect { described_class.start(%w[mb newbucket]) }
        .to output(/location/).to_stdout
      expect(s3_client).to have_received(:create_bucket).with({ bucket: 'newbucket' })
    end
  end

  context 'when testing copy objects' do
    let(:s3_client) { instance_double(Aws::S3::Client) }

    before do
      allow(Aws::S3::Client).to receive(:new).and_return(s3_client)
      allow(s3_client).to receive(:get_object).and_return({})
      allow(File).to receive(:directory?).and_call_original
      allow(File).to receive(:directory?)
        .with('./tmp')
        .and_return(true)
    end

    it 'calls cp s3://distribution/linux/duckdns' do
      described_class.start(%w[cp s3://distribution/linux/duckdns])
      expect(s3_client).to have_received(:get_object)
        .with(response_target: 'duckdns', bucket: 'distribution', key: 'linux/duckdns')
    end

    it 'calls cp s3://distribution/linux/duckdns ./tmp' do
      described_class.start(%w[cp s3://distribution/linux/duckdns ./tmp])
      expect(s3_client).to have_received(:get_object)
        .with(response_target: './tmp/duckdns', bucket: 'distribution', key: 'linux/duckdns')
    end
  end
end
