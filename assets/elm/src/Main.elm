module Main exposing (..)

import Platform.Cmd exposing (batch)
import Data exposing (Model, Msg(..))
import Page.Authentication as Auth
import Page.Page as Page exposing (Page(..))
import View.View exposing (view)
import Update exposing (update)
import Navigation exposing (Location, program)
import Router exposing (locationToRoute)


main : Program Never Model Msg
main =
    Navigation.program locationToMessage
        { init = fromLocation
        , update = update
        , subscriptions = (always Sub.none)
        , view = view
        }


locationToMessage : Location -> Msg
locationToMessage location =
    SetRoute (locationToRoute location)


fromLocation : Location -> ( Model, Cmd Msg )
fromLocation location =
    ( initialState, goToLoginPage )


goToLoginPage : Cmd Msg
goToLoginPage =
    Navigation.newUrl "#/authentication"


initialState : Model
initialState =
    { authenticatedUser = Nothing
    , currentPage = Authentication Auth.initialModel
    }
