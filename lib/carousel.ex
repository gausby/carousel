defmodule Carousel do
  @moduledoc """
  A data structure that implements a queue that loops into it self. It
  is implemented with regular Erlang queues, an element taken out is
  inserted to the end of the queue.
  """
  @opaque t :: %__MODULE__{queue: :queue,
                           position: non_neg_integer(),
                           length: non_neg_integer(),
                           hard_stop: boolean()}
  defstruct queue: {[], []}, position: 0, length: 0, hard_stop: false

  @type options :: [option]
  @type option :: {:hard_stop, boolean}

  @doc """
  Creates a new carousel.

  A carousel can be initialized with items by passing in a list of
  elements.

  One configuration option, `hard_stop`, is currently available. It
  changes the behaviour when taking items out of the carousel. If set
  to `false` (default) it will wrap around to the start of the queue
  when the end has been reached, and continue taking items out until
  it hits the number of requested items.

      iex> Carousel.new([:foo, :bar, :baz])
      ...> |> Carousel.take(4)
      ...> |> elem(0)
      [:foo, :bar, :baz, :foo]

  With hard stop set to `true` it will stop at the last item, even if
  asked for more items than remaining.

      iex> Carousel.new([:foo, :bar, :baz], hard_stop: true)
      ...> |> Carousel.take(4)
      ...> |> elem(0)
      [:foo, :bar, :baz]

  """
  @spec new([any()], options) :: t
  def new(items \\ [], opts \\ [])
  def new(items, opts) when is_list(items) do
    %Carousel{queue: :queue.from_list(items),
              length: length(items),
              hard_stop: Keyword.get(opts, :hard_stop, :false)}
  end
  def new(data, _opts) do
    raise ArgumentError,
      message: "Initial data should be given as a list,"
            <> " got: #{inspect data}"
  end

  @doc """
  Insert a new `item` to the carousel. It will get inserted in the
  back of the queue relative to the current position.
  """
  @spec insert(t, any()) :: t
  def insert(%Carousel{queue: queue, length: len} = carousel, item) do
    %{carousel|queue: :queue.snoc(queue, item),
               length: len + 1}
  end

  @doc """
  Take `n` elements from the carousel.

  See the documentation for `Carousel.new/2` for details on the
  semantics when the last element is reached.
  """
  @spec take(t, non_neg_integer()) :: {[any()], t}
  def take(carousel, n) when is_number(n) and n >= 0 do
    do_cycle(carousel, n)
  end

  # Helpers ------------------------------------------------------------
  defp do_cycle(carousel, n, acc \\ [])
  defp do_cycle(carousel, 0, acc) do
    {Enum.reverse(acc), carousel}
  end
  defp do_cycle(%Carousel{queue: {[], []}} = empty_carousel, _n, _acc) do
    {[], empty_carousel}
  end
  defp do_cycle(%Carousel{queue: queue} = carousel, n, acc) do
    {{:value, item}, temp_queue} = :queue.out(queue)
    new_queue = :queue.snoc(temp_queue, item)
    new_position = rem(carousel.position + 1, carousel.length)

    # if `hard_stop` is `true` it should not be able to wrap around in
    # the same cycle.
    next =
      unless carousel.hard_stop && new_position == 0, do: n - 1, else: 0

    do_cycle(%{carousel|queue: new_queue,
                        position: new_position}, next, [item|acc])
  end
end
