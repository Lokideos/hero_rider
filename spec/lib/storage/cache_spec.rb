# frozen_string_literal: true

RSpec.describe Storage::Cache do
  subject(:cache) { described_class.new }

  describe '#store_for_period' do
    let(:method_args) { { key: 'test', period: 1, value: 'value' } }
    let(:expected_method_args) { { key: "#{Settings.app.name}:test", period: 1, value: 'value' } }

    it 'calls RedisDb.redis.store_for_period with expected parameters' do
      mock_redis_double = double(RedisDb.redis)
      allow(RedisDb).to receive(:redis).and_return(mock_redis_double)
      allow(mock_redis_double).to receive(:setex)

      expect(mock_redis_double).to receive(:setex).with(*expected_method_args.values)

      cache.store_for_period(**method_args)
    end

    it 'stores key for given period of time' do
      cache.store_for_period(key: 'test', period: 2, value: 'value')

      expect(RedisDb.redis.get("#{Settings.app.name}:test")).to eq 'value'
    end
  end

  describe '#exists?' do
    let(:method_args) { { key: 'test' } }
    let(:expected_method_args) { { key: "#{Settings.app.name}:test" } }
    let(:existing_key_name) { 'existing_key' }
    let(:full_existing_key_name) { "#{Settings.app.name}:#{existing_key_name}" }

    before { RedisDb.redis.set(full_existing_key_name, 'value') }

    it 'calls RedisDb.redis.exists? with expected parameters' do
      mock_redis_double = double(RedisDb.redis)
      allow(RedisDb).to receive(:redis).and_return(mock_redis_double)
      allow(mock_redis_double).to receive(:exists?)

      expect(mock_redis_double).to receive(:exists?).with(*expected_method_args.values)

      cache.exists?(**method_args)
    end

    it 'returns true if key exists' do
      expect(cache.exists?(key: existing_key_name)).to be_truthy
    end

    it 'returns false if key does not exist' do
      expect(cache.exists?(key: 'not_valid_key')).to be_falsey
    end
  end
end
