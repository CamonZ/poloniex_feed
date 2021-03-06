defmodule PoloniexWebsocket.Messages.MarketEventTest do
  use ExUnit.Case

  alias PoloniexWebsocket.Messages.MarketEvent, as: MarketEvent

  doctest PoloniexWebsocket.Messages.MarketEvent

  describe "When building an order book update" do
    test "builds a bid order book update" do
      data = [90077516, [["o",1,"0.00004962","0.00000150"]]]
      now = DateTime.from_unix!(1504556374000, :millisecond)

      assert MarketEvent.from_message(data, now) == %{
        events: [
          %{
            nonce: 90077516,
            side: "bid",
            rate: 4962,
            amount: 150,
            recorded_at: now  |> DateTime.to_string,
            type: :order_book_update
          }
        ],
        market: nil
      }
    end

    test "builds an ask order book update" do
      data = [90077516, [["o",0,"0.00004962","0.00000150"]]]
      now = DateTime.from_unix!(1504556374000, :millisecond)

      assert MarketEvent.from_message(data, now) == %{
        events: [
          %{
            nonce: 90077516,
            side: "ask",
            rate: 4962,
            amount: 150,
            recorded_at: now  |> DateTime.to_string,
            type: :order_book_update
          }
        ],
        market: nil
      }
    end
  end

  describe "When building a market trade update" do
    test "and the trade is an uptick" do
      data = [90077516, [["t","13000395",1,"0.00004995","0.00000660",1504480453]]]
      now = DateTime.from_unix!(1504556374000, :millisecond)

      assert MarketEvent.from_message(data, now) == %{
        events: [
          %{
            nonce: 90077516,
            side: "buy",
            rate: 4995,
            amount: 660,
            trade_id: "13000395",
            trade_timestamp: DateTime.from_unix!(1504480453) |> DateTime.to_string,
            recorded_at: now  |> DateTime.to_string,
            type: :market_trade
          }
        ],
        market: nil
      }
    end

    test "and the trade is a downtick" do
      data = [90077516, [["t","13000395",0,"0.00004995","0.00000660",1504480453]]]
      now = DateTime.from_unix!(1504556374000, :millisecond)

      assert MarketEvent.from_message(data, now) == %{
        events: [
          %{
            nonce: 90077516,
            side: "sell",
            rate: 4995,
            amount: 660,
            trade_id: "13000395",
            trade_timestamp: DateTime.from_unix!(1504480453) |> DateTime.to_string,
            recorded_at: now |> DateTime.to_string,
            type: :market_trade
          }
        ],
        market: nil,
      }
    end
  end


  test "builds the order book" do
    data = [
      27366912,
      [
        [
          "i", %{
            "currencyPair" => "BTC_STRAT",
            "orderBook" => [
              %{ "0.00134216" => "1.71288737", "0.00134232" => "13.35069928" },
              %{ "0.00134000" => "1659.01646269", "0.00133188" => "0.52557287" }
            ]
          }
        ]
      ]
    ]

    now =  DateTime.from_unix!(1504556374000, :millisecond)

    assert MarketEvent.from_message(data, now) == %{
      market: "BTC_STRAT",
      events: [
        %{
          nonce: 27366912,
          recorded_at: now |> DateTime.to_string,
          bids: %{
            134000 => 165901646269,
            133188 => 52557287
          },
          asks: %{
            134216 => 171288737,
            134232 => 1335069928
          },
          type: :order_book
        }
      ]
    }
  end
end
