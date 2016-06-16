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

  test "should cycle the items in the carousel" do
    carousel =
      Carousel.new([:foo, :bar, :baz])

    assert {[:foo, :bar, :baz, :foo], %Carousel{}} = Carousel.take(carousel, 4)
  end

  test "should return an empty result list when cycling a carousel without data" do
    assert {[], %Carousel{}} = Carousel.take(Carousel.new(), 4)
  end
end
