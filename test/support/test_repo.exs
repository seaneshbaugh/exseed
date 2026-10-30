defmodule Exseed.TestAdapter do
  @behaviour Ecto.Adapter
  @behaviour Ecto.Adapter.Schema

  defmacro __before_compile__(_env), do: :ok
  def ensure_all_started(_config, _type), do: {:ok, []}
  def init(_config), do: {:ok, Supervisor.child_spec({Agent, fn -> nil end}, []), %{}}
  def checkout(_meta, _opts, fun), do: fun.()
  def checked_out?(_meta), do: false
  def loaders(:binary_id, type), do: [Ecto.UUID, type]
  def loaders(_primitive, type), do: [type]
  def dumpers(:binary_id, type), do: [type, Ecto.UUID]
  def dumpers(_primitive, type), do: [type]
  def autogenerate(:id), do: nil
  def autogenerate(type) when type in [:binary_id, :embed_id], do: Ecto.UUID.generate()

  def insert(_meta, schema, fields, _conflict, returning, _opts) do
    send(self(), {:insert, schema.source, fields})
    {:ok, Enum.map(returning, &{&1, 42})}
  end

  def insert_all(_, _, _, _, _, _, _, _), do: raise("not implemented")
  def update(_, _, _, _, _, _), do: raise("not implemented")
  def delete(_, _, _, _, _), do: raise("not implemented")
end

defmodule Exseed.TestRepo do
  use Ecto.Repo, otp_app: :exseed, adapter: Exseed.TestAdapter
end
