# Taken from https://github.com/elixir-lang/ecto/blob/v1.1.3/test/support/test_repo.exs
# Some slight modifcations to start_link/2 though.

defmodule Exseed.TestAdapter do
  @behaviour Ecto.Adapter

  defmacro __before_compile__(_opts), do: :ok

  def start_link(_repo, _opts), do: :ok

  def stop(_repo), do: :ok

  def stop(_, _, _) do
    :ok
  end

  ## Types

  def load(:binary_id, data), do: Ecto.Type.load(Ecto.UUID, data, &load/2)
  def load(type, data), do: Ecto.Type.load(type, data, &load/2)

  def dump(:binary_id, data), do: Ecto.Type.dump(Ecto.UUID, data, &dump/2)
  def dump(type, data), do: Ecto.Type.dump(type, data, &dump/2)

  def embed_id(%Ecto.Embedded{}), do: Ecto.UUID.generate

  ## Queryable

  def prepare(operation, query), do: {:nocache, {operation, query}}

  def execute(_repo, _, {:all, %{from: {_, SchemaMigration}}}, _, _, _) do
    {length(migrated_versions()),
     Enum.map(migrated_versions(), &List.wrap/1)}
  end

  def execute(_repo, _, {:all, _}, _, _, _) do
    {1, [[1]]}
  end

  def execute(_repo, _meta, {:delete_all, %{from: {_, SchemaMigration}}}, [version], _, _) do
    Process.put(:migrated_versions, List.delete(migrated_versions(), version))
    {1, nil}
  end

  def execute(_repo, _meta, {_, _}, _params, _preprocess, _opts) do
    {1, nil}
  end

  ## Model

  def insert(_repo, %{source: {nil, "schema_migrations"}}, val, _, _, _) do
    version = Keyword.fetch!(val, :version)
    Process.put(:migrated_versions, [version|migrated_versions()])
    {:ok, [version: 1]}
  end

  def insert(repo, model_meta, fields, {key, :id, nil}, return, opts),
    do: insert(repo, model_meta, fields, nil, [key|return], opts)
  def insert(_repo, %{context: nil}, _fields, _autogen, return, _opts),
    do: send(self(), :insert) && {:ok, Enum.zip(return, 1..length(return))}
  def insert(_repo, %{context: {:invalid, _}=res}, _fields, _autogen, _return, _opts),
    do: res

  # Notice the list of changes is never empty.
  def update(_repo, %{context: nil}, [_|_], _filters, _autogen, return, _opts),
    do: send(self(), :update) && {:ok, Enum.zip(return, 1..length(return))}
  def update(_repo, %{context: {:invalid, _}=res}, [_|_], _filters, _autogen, _return, _opts),
    do: res

  def delete(_repo, _model_meta, _filter, _autogen, _opts),
    do: {:ok, []}

  ## Transactions

  def transaction(_repo, _opts, fun) do
    # Makes transactions "trackable" in tests
    send self(), {:transaction, fun}
    try do
      {:ok, fun.()}
    catch
      :throw, {:ecto_rollback, value} ->
        {:error, value}
    end
  end

  def rollback(_repo, value) do
    send self(), {:rollback, value}
    throw {:ecto_rollback, value}
  end

  ## Migrations

  def supports_ddl_transaction? do
    Process.get(:supports_ddl_transaction?) || false
  end

  def execute_ddl(_repo, command, _) do
    Process.put(:last_command, command)
    :ok
  end

  defp migrated_versions do
    Process.get(:migrated_versions) || []
  end
end

Application.put_env(:ecto, Exseed.TestRepo, [])

defmodule Exseed.TestRepo do
  use Ecto.Repo, otp_app: :ecto, adapter: Exseed.TestAdapter
end
