defmodule Chips.ProcessData do

  def add_result_to_tournaments([]) do [] end
  def add_result_to_tournaments(serieses = [%Chips.TournamentSeries{} | _]) do
    Enum.map(serieses, fn(series) ->
      %{ series | tournaments:  add_result(series) }
    end)
  end

  defp add_result(series) do
    Enum.map(series.tournaments, fn(tournament) ->
      if (length(tournament.results) == 1) do
        first_result = Enum.at(tournament.results, 0)
        Map.put(tournament, :result, first_result.prize)
      else
        tournament
      end
    end)
  end

end
