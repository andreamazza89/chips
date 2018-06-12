module Update exposing (update)

import Data exposing (..)
import Navigation exposing (..)
import Page.Authentication as Auth
import Page.MarketPlace as Market
import Page.Page exposing (Page(..))
import Router exposing (resolve)


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
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

        ( MarketPlaceMsg subMsg, MarketPlace subModel ) ->
            let
                ( ( newSubModel, subCmd ), externalMsg ) =
                    Market.update model.authenticatedUser ( subModel, subMsg )
            in
                ( { model | currentPage = MarketPlace newSubModel }, Cmd.map MarketPlaceMsg subCmd )

        ( SetRoute route, _ ) ->
            let
                userExists =
                    isSomething model.authenticatedUser

                page =
                    Router.resolve route userExists
            in
                case page of
                    MarketPlace _ ->
                        ( { model | currentPage = page }, Cmd.map MarketPlaceMsg (Market.initialCmd model.authenticatedUser) )

                    _ ->
                        ( { model | currentPage = page }, Cmd.none )

        -- ignore messages from pages that are not the current one
        ( _, _ ) ->
            ( model, Cmd.none )



-- please move me into some kind of util class soon maybe?


isSomething : Maybe a -> Bool
isSomething subject =
    case subject of
        Just _ ->
            True

        Nothing ->
            False
