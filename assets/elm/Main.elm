module Main exposing (..)

import Html exposing (program)
import Platform.Cmd exposing (batch)
import Data exposing (..)
import View.View exposing (view)
import Queries exposing (..)
import Update exposing (update)


main : Program Never Model Msg
main =
    program
        { init = ( initialState, batch [ fetchSerieses, fetchUsers ] )
        , update = update
        , subscriptions = (always Sub.none)
        , view = view
        }


initialState : Model
initialState =
    { userName = ""
    , userId = "1"
    , email = ""
    , formData = initialFormData
    , halfPercentsSold = 0
    , newTournamentName = ""
    , newTournamentFeeInCents = 0
    , newTournamentSeriesCity = ""
    , newTournamentSeriesName = ""
    , rate = 0
    , stakerId = "0"
    , stuff = "errors go here"
    , tournaments = []
    , tournamentSerieses = []
    , users = []
    }


initialFormData : FormData
initialFormData =
    { user = { name = "", email = "" } }
