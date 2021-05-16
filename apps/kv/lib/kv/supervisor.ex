defmodule KV.Supervisor do
  use Supervisor

  def start_link(opts) do
    Supervisor.start_link(__MODULE__, :ok, opts)
  end

  @impl true
  def init(:ok) do
    children = [
      #  we give the child process a name to avoid having to fetch it from pid
      {KV.Registry, name: KV.Registry},
      {DynamicSupervisor, name: KV.BucketSupervisor, strategy: :one_for_one},
      {Task.Supervisor, name: KV.RouterTasks}
    ]

    #  :one_for_one means that if a child dies, it will be the only one restarted
    # Supervisor.init(children, strategy: :one_for_one)

    # the :one_for_all strategy: the supervisor will kill and restart all of its children processes whenever any one of them dies.
    # see why https://elixir-lang.org/getting-started/mix-otp/dynamic-supervisor.html#supervision-trees
    Supervisor.init(children, strategy: :one_for_all)
  end
end
