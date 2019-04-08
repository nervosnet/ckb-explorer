require "test_helper"

class CkbTransactionTest < ActiveSupport::TestCase
  context "associations" do
    should belong_to(:block)
    should have_many(:account_books)
    should have_many(:accounts).
      through(:account_books)
    should have_many(:cell_inputs)
    should have_many(:cell_outputs)
  end

  context "validations" do
    should validate_presence_of(:transaction_fee)
    should validate_presence_of(:status)
    should validate_numericality_of(:transaction_fee).
      is_greater_than_or_equal_to(0)
  end

  test "#binary_hash should decodes packed string" do
    VCR.use_cassette("blocks/10") do
      SyncInfo.local_inauthentic_tip_block_number
      node_block = CkbSync::Api.get_block("0xed54818adbf956486a192989844d15d77bc937d8bcfcfc5e591a4f9e31e2cd2a").deep_stringify_keys
      CkbSync::Persist.save_block(node_block, "inauthentic")
      packed_block_hash = ["0xed54818adbf956486a192989844d15d77bc937d8bcfcfc5e591a4f9e31e2cd2a".delete_prefix(ENV["DEFAULT_HASH_PREFIX"])].pack("H*")
      block = Block.find_by(block_hash: packed_block_hash)
      ckb_transaction = block.ckb_transactions.first
      assert_equal unpack_attribute(ckb_transaction, "tx_hash"), ckb_transaction.tx_hash
    end
  end
end
