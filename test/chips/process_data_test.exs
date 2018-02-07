defmodule Chips.ProcessDataTest do
  use ExUnit.Case

  alias Chips.{ProcessData, Result, Tournament, TournamentSeries}

  test "processes tournament result when there is one" do
    raw_serieses = [
      %TournamentSeries{
        tournaments: [
          %Tournament{ results: [ %Result{ prize: 42 } ] },
          %Tournament{ results: [ %Result{ prize: 66 } ] },
        ]
      },
      %TournamentSeries{
        tournaments: [
          %Tournament{ results: [ %Result{ prize: 33 } ] },
        ]
      }
    ]

    processed_serieses = raw_serieses |> ProcessData.add_result_to_tournaments()

    processed_series_1_tournaments = Enum.at(processed_serieses, 0).tournaments
    processed_series_2_tournaments = Enum.at(processed_serieses, 1).tournaments

    assert Enum.at(processed_series_1_tournaments, 0).result == 42
    assert Enum.at(processed_series_1_tournaments, 1).result == 66

    assert Enum.at(processed_series_2_tournaments, 0).result == 33
  end

  test "adds no result when there isn't one" do
    raw_serieses = [
      %TournamentSeries{
        tournaments: [
          %Tournament{ results: [ %Result{ prize: 42 } ] },
          %Tournament{ results: [] },
        ]
      }
    ]

    processed_serieses = raw_serieses |> ProcessData.add_result_to_tournaments()

    processed_series_1_tournaments = Enum.at(processed_serieses, 0).tournaments

    assert Enum.at(processed_series_1_tournaments, 0).result == 42
    assert (
      Enum.at(processed_series_1_tournaments, 1)
      |> Map.keys()
      |> Enum.member?(:result) == false
    )
  end

  test "adds no result when there are more than one" do
    raw_serieses = [
      %TournamentSeries{
        tournaments: [
          %Tournament{ results: [ %Result{ prize: 42 }, %Result{ prize: 33 } ] },
        ]
      }
    ]

    processed_serieses = raw_serieses |> ProcessData.add_result_to_tournaments()

    processed_series_1_tournaments = Enum.at(processed_serieses, 0).tournaments

    assert (
      Enum.at(processed_series_1_tournaments, 0)
      |> Map.keys()
      |> Enum.member?(:result) == false
    )
  end

end
