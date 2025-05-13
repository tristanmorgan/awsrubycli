# frozen_string_literal: true

require 'spec_helper'
require 'thor'
require_relative '../../../lib/awscli_kms'

describe Awscli::Kms do
  context 'when credentials available' do
    let(:kms_client) { instance_double(Aws::KMS::Client) }

    before do
      allow(Aws::KMS::Client).to receive(:new).and_return(kms_client)
      allow(kms_client).to receive(:list_keys).and_return(
        keys: [
          {
            key_id: '2632ba26-1619-4c34-af7e-d4416f110161',
            key_arn: 'arn:aws:kms:ap-southeast-2:123456789012:key/2632ba26-1619-4c34-af7e-d4416f110161'
          }
        ],
        truncated: false
      )
      allow(kms_client).to receive(:list_aliases).and_return(
        aliases: [
          {
            alias_name: 'alias/vault',
            alias_arn: 'arn:aws:kms:ap-southeast-2:123456789012:alias/vault',
            target_key_id: '2632ba26-1619-4c34-af7e-d4416f110161'
          }
        ],
        truncated: false
      )
      allow(kms_client).to receive(:schedule_key_deletion).and_return(
        key_id: 'arn:aws:kms:ap-southeast-2:123456789012:key/fba78ea0-210c-4f98-813d-6215095f75b3',
        deletion_date: '2022-12-29 16:52:12 +1100'
      )
      allow(kms_client).to receive(:create_key).and_return(
        key_metadata: {
          aws_account_id: '123456789012',
          key_id: '0fe053ec-b39c-4810-bb25-455c092225e3',
          arn: 'arn:aws:kms:ap-southeast-2:123456789012:key/0fe053ec-b39c-4810-bb25-455c092225e3',
          creation_date: '2022-09-19 14:51:37 +1000',
          enabled: true,
          key_usage: 'ENCRYPT_DECRYPT',
          key_state: 'Enabled',
          origin: 'AWS_KMS',
          key_manager: 'CUSTOMER',
          customer_master_key_spec: 'SYMMETRIC_DEFAULT',
          key_spec: 'SYMMETRIC_DEFAULT',
          encryption_algorithms: [
            'SYMMETRIC_DEFAULT'
          ]
        }
      )
    end

    it 'calls list_aliases' do
      expect { described_class.start(%w[list_aliases]) }
        .to output(/target_key_id/).to_stdout
      expect(kms_client).to have_received(:list_aliases)
    end

    it 'calls list_keys' do
      expect { described_class.start(%w[list_keys]) }
        .to output(/keys/).to_stdout
      expect(kms_client).to have_received(:list_keys)
    end

    it 'calls create_key' do
      expect { described_class.start(%w[create_key]) }
        .to output(/key_metadata/).to_stdout
      expect(kms_client).to have_received(:create_key)
    end

    it 'calls delete_key' do
      expect { described_class.start(%w[delete_key uuid-key-id 7]) }
        .to output(/deletion_date/).to_stdout
      expect(kms_client).to have_received(:schedule_key_deletion)
        .with(key_id: 'uuid-key-id', pending_window_in_days: '7')
    end
  end
end
