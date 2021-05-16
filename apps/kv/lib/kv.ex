defmodule KV do
  use Application

  @impl true
  def start(_type, _args) do
    # Although we don't use the supervisor name below directly,
    # it can be useful when debugging or introspecting the system.

    # The goal of start/2 is to start a supervisor,
    # which will then start any child services or execute any other code our application may need
    KV.Supervisor.start_link(name: KV.Supervisor)
  end
end
