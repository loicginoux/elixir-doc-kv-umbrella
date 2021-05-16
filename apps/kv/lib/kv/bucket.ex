defmodule KV.Bucket do
  # when the supervisor restarts the new bucket, the registry does not know about it.
  # So we will have an empty bucket in the supervisor that nobody can access!
  # To solve this, we want to say that buckets are actually temporary.
  # If they crash, regardless of the reason, they should not be restarted.
  # We can do this by passing the restart: :temporary
  use Agent, restart: :temporary

  @doc """
  Starts a new bucket.
  """
  def start_link(_opts) do
    Agent.start_link(fn -> %{} end)
  end

  @doc """
  Gets a value from the `bucket` by `key`.
  """
  def get(bucket, key) do
    Agent.get(bucket, &Map.get(&1, key))
  end

  @doc """
  Puts the `value` for the given `key` in the `bucket`.
  """
  def put(bucket, key, value) do
    Agent.update(bucket, &Map.put(&1, key, value))
  end

  @doc """
  Deletes `key` from `bucket`.

  Returns the current value of `key`, if `key` exists.
  """
  def delete(bucket, key) do
    Agent.get_and_update(bucket, &Map.pop(&1, key))
  end
end
