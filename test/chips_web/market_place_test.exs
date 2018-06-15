defmodule ChipsWeb.MarketPlaceTest do
  use ChipsWeb.ConnCase

  @test_user %{email: "lol@a.b", password: "psst", user_name: "Gigi"}

  test "creating an action sale for a tournament" do
    # create user (logs in)
    %{
      "token" => token,
      "email" => email,
      "user_name" => user_name
    } =
      build_conn()
      |> post("/api/users", @test_user)
      |> json_response(200)

    # create series
    create_series_body = %{
      query: """
        mutation {
          createTournamentSeries( city: "Vegas", name: "WSOP") { id }
        }
      """
    }

    %{
      "data" => %{"createTournamentSeries" => [%{"id" => series_id}]}
    } =
      build_conn()
      |> put_req_header("authorization", "Token " <> token)
      |> post("/api", create_series_body)
      |> json_response(200)

    # create tournament
    create_tournament_body = %{
      query: """
        mutation {
          createTournament(
            name: "Main",
            feeInCents: 4266,
            tournamentSeriesId: "#{series_id}"
          ) { tournaments { id } }
        }
      """
    }

    %{
      "data" => %{
        "createTournament" => [
          %{"tournaments" => [%{"id" => tourney_id}]}
        ]
      }
    } =
      build_conn()
      |> put_req_header("authorization", "Token " <> token)
      |> post("/api", create_tournament_body)
      |> json_response(200)

    # create action sale
    create_action_sale_body = %{
      query: """
        mutation {
          createActionSale(
            tournamentId: "#{tourney_id}",
            unitsOnSale: 33,
            markup: 1.45
          ) { tournaments { actionSales { userName, unitsOnSale } } }
        }
      """
    }

    %{
      "data" => %{
        "createActionSale" => [
          %{
            "tournaments" => [
              %{
                "actionSales" => [
                  %{"userName" => action_user_name, "unitsOnSale" => action_units_sold}
                ]
              }
            ]
          }
        ]
      }
    } =
      build_conn()
      |> put_req_header("authorization", "Token " <> token)
      |> post("/api", create_action_sale_body)
      |> json_response(200)

    assert action_user_name == @test_user.user_name
    assert action_units_sold == 33
  end
end
