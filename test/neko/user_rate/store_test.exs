defmodule Neko.UserRate.StoreTest do
  use ExUnit.Case, async: true

  alias Neko.UserRate
  alias Neko.UserRate.Store

  # runs before each test
  setup do
    {:ok, store} = Store.start_link
    {:ok, store: store}
  end

  # pass store to each test using 'test context'
  test "stores user_rate by its id", %{store: store} do
    id = 1
    user_rate = %UserRate{id: id}

    assert Store.get(store, id) == nil

    Store.put(store, id, user_rate)
    assert Store.get(store, id) == user_rate
    assert Store.all(store) == [user_rate]

    Store.delete(store, id)
    assert Store.get(store, id) == nil
  end
end
