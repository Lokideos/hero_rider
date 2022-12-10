# frozen_string_literal: true

RSpec.describe Hunters::ChangeServicePasswordService, type: :service do
  subject(:service) { described_class }

  let(:hunter) { Fabricate(:trophy_hunter, password: old_password) }
  let(:old_password) { 'old_password' }
  let(:new_password) { 'new_password' }

  context 'with valid parameters' do
    let(:new_password) { 'new_password' }

    it 'updates service password' do
      expect { service.call(hunter.name, new_password) }
        .to change { hunter.reload.password }
        .from(old_password)
        .to(new_password)
    end
  end

  context 'with invalid parameters' do
    context 'with empty password' do
      let(:new_password) { nil }
      it 'returns failed result object' do
        expect(subject.call(hunter.name, new_password)).to be_a_failure
      end

      it 'does not update service password' do
        expect { service.call(hunter.name, new_password) }
          .to_not change { hunter.reload.password }
      end
    end

    context 'without password' do
      let(:new_password) { '' }

      it 'returns failed result object' do
        expect(subject.call(hunter.name, new_password)).to be_a_failure
      end

      it 'does not update service password' do
        expect { service.call(hunter.name, new_password) }
          .to_not change { hunter.reload.password }
      end
    end

    context 'with non-existing hunter name provided' do
      let(:hunter_name) { 'John Dough' }

      it 'returns failed result object' do
        expect(subject.call(hunter_name, new_password)).to be_a_failure
      end

      it 'does not update service password' do
        expect { service.call(hunter_name, new_password) }
          .to_not change { hunter.reload.password }
      end
    end
  end
end
