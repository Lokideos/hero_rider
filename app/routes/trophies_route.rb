# frozen_string_literal: true

class TrophiesRoute < Roda
  plugin :hooks
  plugin :render, engine: 'slim', views: Application.root.concat('/app/views/trophies')

  route do |r|
    r.get do
      render('show', locals: {
               psn_id: params['player_account'],
               trophy_title: params['trophy_title'],
               trophy_description: params['trophy_description'],
               trophy_type: params['trophy_type'],
               trophy_rarity: params['trophy_rarity'],
               trophy_icon_url: params['icon_url'],
               game_title: params['game_title']
             })
    end
  end

  private

  def params
    request.params
  end
end
