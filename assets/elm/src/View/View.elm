module View.View exposing (view)

import Html exposing (..)
import Data exposing (..)
import Page.Authentication as Auth exposing (view)
import Page.MarketPlace as Market exposing (view)
import Page.Page as Page exposing (Page(..))
import User exposing (AuthenticatedUser)


view : Model -> Html Msg
view model =
    case model.currentPage of
        Authentication authState ->
            div []
                [ viewAuthenticatedUser model.authenticatedUser
                , Auth.view authState
                    |> Html.map AuthenticationMsg
                ]

        MarketPlace marketState ->
            div []
                [ viewAuthenticatedUser model.authenticatedUser
                , Market.view marketState
                    |> Html.map MarketPlaceMsg
                ]

        OldPage ->
            div []
                [ text "this is the page that needs removing" ]


viewAuthenticatedUser : Maybe User.AuthenticatedUser -> Html Msg
viewAuthenticatedUser user =
    case user of
        Just user ->
            div [] [ text ("hello " ++ user.userName ++ ", you are logged in") ]

        Nothing ->
            div [] [ text "no user logged in" ]
