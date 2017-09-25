# http://blog.plataformatec.com.br/2015/10/mocks-and-explicit-contracts/
defmodule Neko.Shikimori.Client.Mock do
  @behaviour Neko.Shikimori.Client

  def get_user_rates!(user_id) do
    [
      %Neko.UserRate{id: 1, user_id: user_id, target_id: 1,
        target_type: "anime", score: 9, status: "completed",
        rewatches: 0, episodes: 24, volumes: 0, chapters: 0},
      %Neko.UserRate{id: 2, user_id: user_id, target_id: 2,
        target_type: "anime", score: 10, status: "completed",
        rewatches: 0, episodes: 12, volumes: 0, chapters: 0}
    ]
  end

  def get_achievements!(user_id) do
    [
      %Neko.Achievement{user_id: user_id, neko_id: "animelist",
        level: 0, progress: 50}
    ]
  end
end
