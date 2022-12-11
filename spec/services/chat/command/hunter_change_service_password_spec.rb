# frozen_string_literal: true

RSpec.describe Chat::Command::HunterChangeServicePassword do
  subject(:service) { described_class }

  let(:trophy_hunter) { Fabricate(:trophy_hunter) }
  let(:new_password) { 'new_password' }
  let(:player_username) { 'player_username' }
  let(:message_type) { 'message' }
  let(:command) do
    {
      message_type => {
        'from' => {
          'username' => player_username
        },
        'text' => "/hunter_change_service_password #{trophy_hunter.name} #{new_password}"
      }
    }
  end

  describe '#call' do
    context 'when user is not an admin' do
      let!(:player) { Fabricate(:player, telegram_username: player_username, admin: false) }

      it 'does not assign anything to message' do
        expect(service.call(command, message_type).message).to be_nil
      end
    end

    context 'when user is an admin' do
      let!(:player) { Fabricate(:player, telegram_username: player_username, admin: true) }

      context 'when password assignment is successful' do
        it 'assigns correct value to message' do
          expect(service.call(command, message_type).message)
            .to eq(["Пароль для охотника #{trophy_hunter.name} успешно обновлен"])
        end
      end

      context 'when password assignment is not successful' do
        let(:new_password) { nil }

        it 'assigns correct value to message' do
          expect(service.call(command, message_type).message).to eq(['Новый пароль не может быть пустым'])
        end
      end
    end
  end
end
