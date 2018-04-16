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
    { userId = "1"
    , formData = initialFormData
    , stuff = "errors go here"
    , tournamentSerieses = []
    , users = []
    }


initialFormData : FormData
initialFormData =
    { result = { prize = 0 }
    , stakingContract = { percentsSold = 0, rate = 0, stakerId = "" }
    , tournament = { name = "", feeInCents = 0 }
    , tournamentSeries = { city = "", name = "" }
    , user = { name = "", email = "" }
    }
