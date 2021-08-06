# frozen_string_literal: true

RSpec.describe Errors, type: :helper do
  subject(:instance_with_errors) { klass.new }

  let(:klass) do
    Class.new do
      include Errors

      attr_reader :response

      def initialize
        @response = Rack::MockResponse.new(200, {}, {})
      end
    end
  end

  describe '#not_found_response' do
    it 'updates response status to 200' do
      instance_with_errors.not_found_response

      expect(instance_with_errors.response.status).to eq(404)
    end

    it 'set response content-type to application/json' do
      instance_with_errors.not_found_response

      expect(instance_with_errors.response['Content-Type']).to eq('application/json')
    end

    it 'returns correct JSON' do
      correct_json = { status: 'Page not found' }.to_json

      expect(instance_with_errors.not_found_response).to eq(correct_json)
    end
  end
end
