defmodule ChipsWeb.MarketPlaceTest do
  use ChipsWeb.ConnCase

  @test_user_player %{email: "lol@a.b", password: "psst", user_name: "Gigi"}
  @test_user_staker %{email: "wow@a.b", password: "psst", user_name: "Mario"}

  test "creating an action sale for a tournament" do
    # create user (logs in)
    %{
      "token" => player_token,
      "email" => player_email,
      "user_name" => player_user_name
    } =
      build_conn()
      |> post("/api/users", @test_user_player)
      |> json_response(200)

    %{
      "token" => staker_token,
      "email" => staker_email,
      "user_name" => staker_user_name
    } =
      build_conn()
      |> post("/api/users", @test_user_staker)
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
      |> put_req_header("authorization", "Token " <> player_token)
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
      |> put_req_header("authorization", "Token " <> player_token)
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
          ) { tournaments { actionSales { id, userName, unitsOnSale } } }
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
                  %{
                    "id" => sale_id,
                    "userName" => action_user_name,
                    "unitsOnSale" => action_units_sold
                  }
                ]
              }
            ]
          }
        ]
      }
    } =
      build_conn()
      |> put_req_header("authorization", "Token " <> player_token)
      |> post("/api", create_action_sale_body)
      |> json_response(200)

    # purchase action
    purchase_action_body = %{
      query: """
        mutation {
          createActionPurchase(
            actionSaleId: "#{sale_id}",
            unitsBought: 10,
          ) { tournaments { actionSales { actionPurchases { userName, unitsBought  } } } }
        }
      """
    }

    %{
      "data" => %{
        "createActionPurchase" => [
          %{
            "tournaments" => [
              %{
                "actionSales" => [
                  %{
                    "actionPurchases" => [
                      %{"userName" => purchaser_name, "unitsBought" => units_bought}
                    ]
                  }
                ]
              }
            ]
          }
        ]
      }
    } =
      build_conn()
      |> put_req_header("authorization", "Token " <> staker_token)
      |> post("/api", purchase_action_body)
      |> json_response(200)

    # publish result for the action sale
    publish_result_body = %{
      query: """
        mutation {
          createActionSaleResult(
            actionSaleId: "#{sale_id}",
            actionSaleResult: 666666,
          ) { tournaments { actionSales { result } } }
        }
      """
    }

    %{
      "data" => %{
        "createActionSaleResult" => [
          %{
            "tournaments" => [
              %{
                "actionSales" => [
                  %{
                    "result" => sale_result
                  }
                ]
              }
            ]
          }
        ]
      }
    } =
      build_conn()
      |> put_req_header("authorization", "Token " <> staker_token)
      |> post("/api", publish_result_body)
      |> json_response(200)

    assert action_user_name == @test_user_player.user_name
    assert action_units_sold == 33
    assert purchaser_name == @test_user_staker.user_name
    assert units_bought == 10
    assert sale_result == 666_666
  end
end
