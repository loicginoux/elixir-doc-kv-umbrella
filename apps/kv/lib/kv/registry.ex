# iex> {:ok, registry} = GenServer.start_link(KV.Registry, :ok)
# {:ok, #PID<0.136.0>}
# iex> GenServer.cast(registry, {:create, "shopping"})
# :ok
# iex> {:ok, bk} = GenServer.call(registry, {:lookup, "shopping"})
# {:ok, #PID<0.174.0>}

defmodule KV.Registry do
  use GenServer

  ## Client API

  @doc """
  Starts the registry.
  """
  def start_link(opts) do
    GenServer.start_link(__MODULE__, :ok, opts)
  end

  @doc """
  Looks up the bucket pid for `name` stored in `server`.

  Returns `{:ok, pid}` if the bucket exists, `:error` otherwise.
  """
  def lookup(server, name) do
    GenServer.call(server, {:lookup, name})
  end

  @doc """
  Ensures there is a bucket associated with the given `name` in `server`.
  """
  def create(server, name) do
    GenServer.cast(server, {:create, name})
  end

  ## Defining GenServer Callbacks

  # The @impl true informs the compiler that our intention for the subsequent function definition is to define a callback
  @impl true
  def init(:ok) do
    names = %{}
    refs = %{}
    {:ok, {names, refs}}
  end

  # handle_call/3 must be used for synchronous requests.
  # This should be the default choice as waiting for the server reply is a useful backpressure mechanism.
  @impl true
  def handle_call({:lookup, name}, _from, state) do
    {names, _} = state
    {:reply, Map.fetch(names, name), state}
  end

  # handle_cast/2 must be used for asynchronous requests, when you don’t care about a reply.
  # A cast does not even guarantee the server has received the message
  @impl true
  def handle_cast({:create, name}, {names, refs}) do
    if Map.has_key?(names, name) do
      {:noreply, {names, refs}}
    else
      # {:ok, pid} = KV.Bucket.start_link([])
      {:ok, pid} = DynamicSupervisor.start_child(KV.BucketSupervisor, KV.Bucket)
      ref = Process.monitor(pid)
      refs = Map.put(refs, ref, name)
      names = Map.put(names, name, pid)
      {:noreply, {names, refs}}
    end
  end

  # handle_info/2 must be used for all other messages a server may receive
  # that are not sent via GenServer.call/2 or GenServer.cast/2,
  # including regular messages sent with send/2
  @impl true
  def handle_info({:DOWN, ref, :process, _pid, _reason}, {names, refs}) do
    {name, refs} = Map.pop(refs, ref)
    names = Map.delete(names, name)
    {:noreply, {names, refs}}
  end

  @impl true
  def handle_info(_msg, state) do
    {:noreply, state}
  end
end
