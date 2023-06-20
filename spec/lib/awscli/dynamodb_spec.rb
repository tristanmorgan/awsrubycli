# frozen_string_literal: true

require 'spec_helper'
require 'thor'
require_relative '../../../lib/awscli_dynamodb'

describe Awscli::Dynamodb do
  context 'when credentials available' do
    let(:dydb_client) { instance_double(Aws::DynamoDB::Client) }

    before do
      allow(Aws::DynamoDB::Client).to receive(:new).and_return(dydb_client)
      allow(dydb_client).to receive(:list_tables).and_return(
        table_names: [
          'terraform-lock'
        ]
      )
      allow(dydb_client).to receive(:describe_table).and_return(
        table: {
          attribute_definitions: [
            {
              attribute_name: 'LockID',
              attribute_type: 'S'
            }
          ],
          table_name: 'terraform-lock',
          key_schema: [
            {
              attribute_name: 'LockID',
              key_type: 'HASH'
            }
          ],
          table_status: 'ACTIVE',
          creation_date_time: '2023-06-21 09:32:04 +1000',
          provisioned_throughput: {
            last_increase_date_time: '1970-01-01 10:00:00 +1000',
            last_decrease_date_time: '1970-01-01 10:00:00 +1000',
            number_of_decreases_today: 0,
            read_capacity_units: 5,
            write_capacity_units: 5
          },
          table_size_bytes: 0,
          item_count: 0,
          table_arn: 'arn:aws:dynamodb:ddblocal:000000000000:table/terraform-lock'
        }
      )
      allow(dydb_client).to receive(:delete_table).and_return(
        table_description: {
          item_count: 0,
          provisioned_throughput: {
            number_of_decreases_today: 0,
            read_capacity_units: 5,
            write_capacity_units: 5
          },
          table_name: 'terraform-lock',
          table_size_bytes: 0,
          table_status: 'DELETING'
        }
      )
    end

    it 'calls list_tables' do
      expect { described_class.start(%w[list_tables]) }
        .to output(/terraform-lock/).to_stdout
    end

    it 'calls describe_table' do
      expect { described_class.start(%w[describe_table terraform-lock]) }
        .to output(/terraform-lock/).to_stdout
      expect(dydb_client).to have_received(:describe_table).with({ table_name: 'terraform-lock' })
    end

    it 'calls delete_table' do
      expect { described_class.start(%w[delete_table terraform-lock]) }
        .to output(/terraform-lock/).to_stdout
      expect(dydb_client).to have_received(:delete_table).with({ table_name: 'terraform-lock' })
    end
  end
end
