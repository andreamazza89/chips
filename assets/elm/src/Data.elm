module Data exposing (..)

import Page.Page exposing (Page(..))
import Page.Authentication as Auth
import Page.MarketPlace as Market
import Router exposing (Route(..))
import User exposing (AuthenticatedUser)


type alias Model =
    { authenticatedUser : Maybe AuthenticatedUser
    , currentPage : Page
    }


type Msg
    = AuthenticationMsg Auth.Msg
    | MarketPlaceMsg Market.Msg
    | SetRoute Route
