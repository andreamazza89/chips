module Update exposing (update)

import Data exposing (..)
import Navigation exposing (..)
import Page.Authentication as Auth
import Page.MarketPlace as Market
import Page.Page exposing (Page(..))
import Router exposing (resolve)


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case model.authenticatedUser of
        Nothing ->
            case ( msg, model.currentPage ) of
                ( AuthenticationMsg subMsg, Authentication subModel ) ->
                    let
                        ( ( newSubModel, subCmd ), externalMsg ) =
                            Auth.update ( subModel, subMsg )
                    in
                        case externalMsg of
                            Auth.NoOp ->
                                ( { model | currentPage = Authentication newSubModel }, Cmd.map AuthenticationMsg subCmd )

                            Auth.SetUser user ->
                                ( { model | authenticatedUser = Just user }, Navigation.newUrl "#/marketplace" )

                ( _, _ ) ->
                    ( { model | authenticatedUser = Nothing }, Cmd.none )

        Just user ->
            case ( msg, model.currentPage ) of
                ( MarketPlaceMsg subMsg, MarketPlace subModel ) ->
                    let
                        ( ( newSubModel, subCmd ), externalMsg ) =
                            Market.update user ( subModel, subMsg )
                    in
                        ( { model | currentPage = MarketPlace newSubModel }, Cmd.map MarketPlaceMsg subCmd )

                ( SetRoute route, _ ) ->
                    case Router.resolve route of
                        MarketPlace marketModel ->
                            ( { model | currentPage = MarketPlace marketModel }, Cmd.map MarketPlaceMsg (Market.initialCmd user) )

                        page ->
                            ( { model | currentPage = page }, Cmd.none )

                -- ignore messages from pages that are not the current one
                ( _, _ ) ->
                    ( model, Cmd.none )
