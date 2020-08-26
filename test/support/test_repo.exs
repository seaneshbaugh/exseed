# Taken from https://github.com/elixir-lang/ecto/blob/v1.1.3/test/support/test_repo.exs
# Some slight modifcations to start_link/2 though.


defmodule Exseed.TestAdapter do
  @behaviour Ecto.Adapter
  @behaviour Ecto.Adapter.Queryable
  @behaviour Ecto.Adapter.Schema
  @behaviour Ecto.Adapter.Transaction

  defmacro __before_compile__(_opts), do: :ok

  def ensure_all_started(_, _) do
    {:ok, []}
  end

  def init(opts) do
    :ecto   = opts[:otp_app]
    "user"  = opts[:username]
    "pass"  = opts[:password]
    "hello" = opts[:database]
    "local" = opts[:hostname]

    {:ok, Supervisor.Spec.worker(Task, [fn -> :timer.sleep(:infinity) end]), %{meta: :meta}}
  end

  def checkout(_mod, _opts, fun) do
    send self(), {:checkout, fun}
    fun.()
  end

  ## Types

  def loaders(:binary_id, type), do: [Ecto.UUID, type]
  def loaders(_primitive, type), do: [type]

  def dumpers(:binary_id, type), do: [type, Ecto.UUID]
  def dumpers(_primitive, type), do: [type]

  def autogenerate(:id), do: nil
  def autogenerate(:embed_id), do: Ecto.UUID.autogenerate
  def autogenerate(:binary_id), do: Ecto.UUID.bingenerate

  ## Queryable

  def prepare(operation, query), do: {:nocache, {operation, query}}

  def execute(_, _, {:nocache, {:all, query}}, _, _) do
    send self(), {:all, query}
    Process.get(:test_repo_all_results) || results_for_all_query(query)
  end

  def execute(_, _meta, {:nocache, {op, query}}, _params, _opts) do
    send self(), {op, query}
    {1, nil}
  end

  def stream(_, _meta, {:nocache, {:all, query}}, _params, _opts) do
    Stream.map([:execute], fn :execute ->
      send self(), {:stream, query}
      results_for_all_query(query)
    end)
  end

  defp results_for_all_query(%{select: %{fields: [_ | _] = fields}}) do
    values = List.duplicate(nil, length(fields) - 1)
    {1, [[1 | values]]}
  end

  defp results_for_all_query(%{select: %{fields: []}}) do
    {1, [[]]}
  end

  ## Schema

  def insert_all(_, meta, header, rows, on_conflict, returning, _opts) do
    meta = Map.merge(meta, %{header: header, on_conflict: on_conflict, returning: returning})
    send(self(), {:insert_all, meta, rows})
    {1, nil}
  end

  def insert(_, %{context: nil} = meta, fields, on_conflict, returning, _opts) do
    meta = Map.merge(meta, %{fields: fields, on_conflict: on_conflict, returning: returning})
    send(self(), {:insert, meta})
    {:ok, Enum.zip(returning, 1..length(returning))}
  end

  def insert(_, %{context: context}, _fields, _on_conflict, _returning, _opts) do
    context
  end

  # Notice the list of changes is never empty.
  def update(_, %{context: nil} = meta, [_ | _] = changes, filters, returning, _opts) do
    meta = Map.merge(meta, %{changes: changes, filters: filters, returning: returning})
    send(self(), {:update, meta})
    {:ok, Enum.zip(returning, 1..length(returning))}
  end

  def update(_, %{context: context}, [_ | _], _filters, _returning, _opts) do
    context
  end

  def delete(_, %{context: nil} = meta, filters, _opts) do
    meta = Map.merge(meta, %{filters: filters})
    send(self(), {:delete, meta})
    {:ok, []}
  end

  def delete(_, %{context: context}, _filters, _opts) do
    context
  end

  ## Transactions

  def transaction(mod, _opts, fun) do
    # Makes transactions "trackable" in tests
    Process.put({mod, :in_transaction?}, true)
    send self(), {:transaction, fun}
    try do
      {:ok, fun.()}
    catch
      :throw, {:ecto_rollback, value} ->
        {:error, value}
    after
      Process.delete({mod, :in_transaction?})
    end
  end

  def in_transaction?(mod) do
    Process.get({mod, :in_transaction?}) || false
  end

  def rollback(_, value) do
    send self(), {:rollback, value}
    throw {:ecto_rollback, value}
  end
end

Application.put_env(:ecto, Exseed.TestRepo, [user: "invalid"])

defmodule Exseed.TestRepo do
  use Ecto.Repo, otp_app: :ecto, adapter: Exseed.TestAdapter

  def init(type, opts) do
    opts = [url: "ecto://user:pass@local/hello"] ++ opts
    opts[:parent] && send(opts[:parent], {__MODULE__, type, opts})
    {:ok, opts}
  end
end

Exseed.TestRepo.start_link()







# defmodule Exseed.TestAdapter do
#   @behaviour Ecto.Adapter

#   defmacro __before_compile__(_opts), do: :ok

#   def start_link(_repo, _opts), do: :ok

#   def stop(_repo), do: :ok

#   def stop(_, _, _) do
#     :ok
#   end

#   ## Types

#   def load(:binary_id, data), do: Ecto.Type.load(Ecto.UUID, data, &load/2)
#   def load(type, data), do: Ecto.Type.load(type, data, &load/2)

#   def dump(:binary_id, data), do: Ecto.Type.dump(Ecto.UUID, data, &dump/2)
#   def dump(type, data), do: Ecto.Type.dump(type, data, &dump/2)

#   def embed_id(%Ecto.Embedded{}), do: Ecto.UUID.generate

#   ## Queryable

#   def prepare(operation, query), do: {:nocache, {operation, query}}

#   def execute(_repo, _, {:all, %{from: {_, SchemaMigration}}}, _, _, _) do
#     {length(migrated_versions()),
#      Enum.map(migrated_versions(), &List.wrap/1)}
#   end

#   def execute(_repo, _, {:all, _}, _, _, _) do
#     {1, [[1]]}
#   end

#   def execute(_repo, _meta, {:delete_all, %{from: {_, SchemaMigration}}}, [version], _, _) do
#     Process.put(:migrated_versions, List.delete(migrated_versions(), version))
#     {1, nil}
#   end

#   def execute(_repo, _meta, {_, _}, _params, _preprocess, _opts) do
#     {1, nil}
#   end

#   ## Model

#   def insert(_repo, %{source: {nil, "schema_migrations"}}, val, _, _, _) do
#     version = Keyword.fetch!(val, :version)
#     Process.put(:migrated_versions, [version|migrated_versions()])
#     {:ok, [version: 1]}
#   end

#   def insert(repo, model_meta, fields, {key, :id, nil}, return, opts),
#     do: insert(repo, model_meta, fields, nil, [key|return], opts)
#   def insert(_repo, %{context: nil}, _fields, _autogen, return, _opts),
#     do: send(self(), :insert) && {:ok, Enum.zip(return, 1..length(return))}
#   def insert(_repo, %{context: {:invalid, _}=res}, _fields, _autogen, _return, _opts),
#     do: res

#   # Notice the list of changes is never empty.
#   def update(_repo, %{context: nil}, [_|_], _filters, _autogen, return, _opts),
#     do: send(self(), :update) && {:ok, Enum.zip(return, 1..length(return))}
#   def update(_repo, %{context: {:invalid, _}=res}, [_|_], _filters, _autogen, _return, _opts),
#     do: res

#   def delete(_repo, _model_meta, _filter, _autogen, _opts),
#     do: {:ok, []}

#   ## Transactions

#   def transaction(_repo, _opts, fun) do
#     # Makes transactions "trackable" in tests
#     send self(), {:transaction, fun}
#     try do
#       {:ok, fun.()}
#     catch
#       :throw, {:ecto_rollback, value} ->
#         {:error, value}
#     end
#   end

#   def rollback(_repo, value) do
#     send self(), {:rollback, value}
#     throw {:ecto_rollback, value}
#   end

#   ## Migrations

#   def supports_ddl_transaction? do
#     Process.get(:supports_ddl_transaction?) || false
#   end

#   def execute_ddl(_repo, command, _) do
#     Process.put(:last_command, command)
#     :ok
#   end

#   defp migrated_versions do
#     Process.get(:migrated_versions) || []
#   end
# end

# Application.put_env(:ecto, Exseed.TestRepo, [])

# defmodule Exseed.TestRepo do
#   use Ecto.Repo, otp_app: :ecto, adapter: Exseed.TestAdapter
# end
