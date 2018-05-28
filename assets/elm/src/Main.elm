module Main exposing (..)

import Platform.Cmd exposing (batch)
import Data exposing (..)
import Page.Foo as Foo
import View.View exposing (view)
import Queries exposing (..)
import Update exposing (update)
import Navigation exposing (Location, program)
import Route exposing (spitMsgFromLocation)


main : Program Never Model Msg
main =
    Navigation.program spitMsgFromLocation
        { init = fromLocation
        , update = update
        , subscriptions = (always Sub.none)
        , view = view
        }


fromLocation : Location -> ( Model, Cmd Msg )
fromLocation location =
    ( initialState, batch [ fetchMoneis, fetchSerieses, fetchUsers ] )


initialState : Model
initialState =
    { userId = "1"
    , currentPage = Foo Foo.initialModel
    , formData = initialFormData
    , moneis = []
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
