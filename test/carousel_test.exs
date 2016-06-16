defmodule CarouselTest do
  use ExUnit.Case
  doctest Carousel

  test "should be able to insert into the carousel queue" do
    carousel = Carousel.new
    assert (Carousel.insert(carousel, :foo)).queue == {[:foo], []}
  end

  test "initialization with no initial data" do
    carousel = Carousel.new
    assert carousel.queue == {[], []}
  end

  test "initialization with a list of data" do
    carousel = Carousel.new([:foo, :bar, :baz])
    assert carousel.queue == {[:baz], [:foo, :bar]}
  end

  test "inserted data should come out the same order it went in" do
    data = [:foo, :bar, :baz, :quun]
    queue =
      Enum.reduce(data, Carousel.new, fn item, acc ->
        Carousel.insert(acc, item)
      end)

    assert {^data, _} = Carousel.take(queue, 4)
  end

  test "inserted data should come out the same order it went in (with initial data)" do
    data = [:foo, :bar, :baz, :quun]
    queue =
      Enum.reduce(Enum.drop(data, 2), Carousel.new(Enum.take(data, 2)), fn item, acc ->
        Carousel.insert(acc, item)
      end)

    assert {^data, _} = Carousel.take(queue, 4)
  end

  test "should cycle the items in the carousel" do
    carousel =
      Carousel.new([:foo, :bar, :baz])

    assert {[:foo, :bar, :baz, :foo], %Carousel{}} = Carousel.take(carousel, 4)
  end

  test "should return an empty result list when cycling a carousel without data" do
    assert {[], %Carousel{}} = Carousel.take(Carousel.new(), 4)
  end
end
