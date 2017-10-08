# https://elixirschool.com/lessons/specifics/plug/#testing-a-plug
# https://github.com/elixir-lang/plug/blob/master/test/plug/parsers/json_test.exs
defmodule Neko.RouterTest do
  use ExUnit.Case, async: true
  use Plug.Test

  import Mox

  alias Neko.Router

  @opts Router.init([])

  # TODO: can we async: true here - it's okay with anime store
  #       since it's read-only but achievements and user rates
  #       are changed in store (stores are accessed by user_id
  #       so it's a problem if user_ids are the same) =>
  #       use `async: false`
  #
  #       this can be fixed by starting store registries with
  #       unique names in application.exs - that is don't start
  #       registries as part of supervision tree but do it here
  #       providing unique names (just like in registry tests)
  #
  # TODO: think of how to provide a lot of seed data
  setup do
    Neko.Shikimori.Client.Mock
    |> Mox.stub(:get_user_rates!, fn(_user_id) -> [] end)
    |> Mox.stub(:get_achievements!, fn(_user_id) -> [] end)
    |> Mox.stub(:get_animes!, fn -> [] end)

    request = %Neko.Request{
      id: 3,
      user_id: 1,
      target_id: 3,
      score: 10,
      status: "completed",
      episodes: 24,
      action: "put"
    }

    # all custom options will be merged into context which is
    # a map containing all the information about current test, e.g.:
    #
    # %{async: true, case: Neko.RouterTest, describe: "/user_rate",
    #  file: <filename>, line: 25, registered: %{}, test: <testname>,
    #  type: :test, request: <request>}
    {:ok, request: request}
  end

  describe "/user_rate" do
    test "returns new achievements", context do
      json = Poison.encode!(context.request)
      conn =
        json_post_conn("/user_rate", json)
        |> Router.call(@opts)

      assert conn.state == :sent
      assert conn.status == 201
      assert conn.resp_body == Poison.encode!(
        %{
          added: MapSet.new([
            %Neko.Achievement{user_id: 1, neko_id: "animelist", level: 2, progress: 0}
          ]),
          removed: MapSet.new(),
          updated: MapSet.new([
            %Neko.Achievement{user_id: 1, neko_id: "animelist", level: 1, progress: 100}
          ])
        }
      )
    end

    test "returns 401 without authorization token", context do
      json = Poison.encode!(context.request)
      conn = json_post_conn("/user_rate", json)
            |> put_req_header("authorization", "bar")
            |> Router.call(@opts)

      assert conn.state == :sent
      assert conn.status == 401
      assert conn.resp_body == "Not Authorized"
    end

    test "returns 404 for missing page", context do
      json = Poison.encode!(context.request)
      conn = json_post_conn("/missing", json) |> Router.call(@opts)

      assert conn.state == :sent
      assert conn.status == 404
      assert conn.resp_body == "oops"
    end
  end

  defp json_post_conn(path, json) do
    conn(:post, path, json)
    |> put_req_header("content-type", "application/json")
    |> put_req_header("authorization", "foo")
  end
end
