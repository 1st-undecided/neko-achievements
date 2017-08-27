defmodule Neko.Achievement do
  # "For maximum performance, make sure you
  # @derive [Poison.Encoder] for any struct you plan on encoding."
  @derive [Poison.Encoder]

  defstruct ~w(
    user_id
    neko_id
    level
    progress
  )a

  alias Neko.Achievement.Store.Registry

  def load(user_id) do
    case Registry.lookup(user_id) do
      {:ok, _store} -> :ok
      :error ->
        Registry.fetch(user_id)
        |> Neko.Achievement.Store.set(achievements(user_id))
    end
  end

  defp achievements(user_id) do
    Neko.Shikimori.Client.get_achievements!(user_id)
  end
end
