defmodule CarouselTest do
  use ExUnit.Case
  doctest Carousel

  describe "initialization" do
    test "with no initial data" do
      carousel = Carousel.new

      assert carousel.queue == {[], []}
      assert carousel.length == 0
    end

    test "with a list of data" do
      carousel = Carousel.new([:foo, :bar, :baz])

      assert carousel.queue == {[:baz], [:foo, :bar]}
      assert carousel.length == 3
    end
  end

  describe "inserting data" do
    test "should be able to insert into the carousel queue" do
      carousel =
        Carousel.new
        |> Carousel.insert(:foo)

      assert carousel.queue == {[:foo], []}
      assert carousel.length == 1
    end

    test "data should come out the same order it went in" do
      data = [:foo, :bar, :baz, :quun]
      queue =
        Enum.reduce(data, Carousel.new, fn item, acc ->
          Carousel.insert(acc, item)
        end)

      assert {^data, _} = Carousel.take(queue, 4)
    end

    test "data should come out the same order it went in (with initial data)" do
      data = [:foo, :bar, :baz, :quun]
      queue =
        Enum.reduce(Enum.drop(data, 2), Carousel.new(Enum.take(data, 2)), fn item, acc ->
          Carousel.insert(acc, item)
        end)

      assert {^data, _} = Carousel.take(queue, 4)
    end
  end

  describe "cycling / receiving items" do
    test "return an empty result list when cycling a carousel without data" do
      assert {[], %Carousel{}} = Carousel.take(Carousel.new(), 4)
    end

    test "advance position when taking items from the carousel" do
      carousel = Carousel.new([:foo, :bar, :baz])

      assert {_, %Carousel{position: 1}} = Carousel.take(carousel, 1)
    end

    test "cycling items (no hard stop - wrap around)" do
      carousel = Carousel.new([:foo, :bar, :baz])

      assert {[:foo, :bar, :baz, :foo], %Carousel{position: 1}} = Carousel.take(carousel, 4)
    end

    test "cycling items (with hard stop - no wrap around)" do
      carousel = Carousel.new([:foo, :bar, :baz], hard_stop: true)

      assert {[:foo, :bar, :baz], %Carousel{position: 0}} = Carousel.take(carousel, 4)
    end
  end
end
