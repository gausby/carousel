defmodule Carousel do
  @moduledoc """
  A data structure that implements a queue that loops into it self. It
  is implemented with regular Erlang queues, an element taken out is
  inserted to the end of the queue.
  """
  defstruct queue: {[], []}

  @doc """
  Create a new carousel.

  A carousel can be initialized with items by passing in a list of
  elements.
  """
  def new(items \\ [], _opts \\ []) do
    %Carousel{queue: :queue.from_list(items)}
  end

  @doc """
  Insert a new item to the carousel. It will get inserted in the back
  so it will get returned when the carousel has made a cycle.
  """
  def insert(%Carousel{queue: queue} = carousel, item) do
    %{carousel|queue: :queue.snoc(queue, item)}
  end

  @doc """
  Take `n` elements from the carousel. If `n` is bigger than the queue
  it will repeat items.
  """
  def take(carousel, n) when is_number(n) and n >= 0 do
    do_cycle(carousel, n)
  end

  # Helpers ------------------------------------------------------------
  defp do_cycle(carousel, n, acc \\ [])
  defp do_cycle(carousel, 0, acc) do
    {Enum.reverse(acc), carousel}
  end
  defp do_cycle(%Carousel{queue: queue} = carousel, n, acc) do
    {{:value, item}, temp_queue} = :queue.out(queue)
    new_queue = :queue.snoc(temp_queue, item)

    do_cycle(%{carousel|queue: new_queue}, n - 1, [item|acc])
  end
end
