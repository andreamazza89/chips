module Main exposing (..)

import Html exposing (Html, text)


type alias Model =
    {}


type Msg
    = Nothing


main : Program Never Model Msg
main =
    Html.program
        { init = ( {}, Cmd.none )
        , update = update
        , subscriptions = (always Sub.none)
        , view = view
        }


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        Nothing ->
            ( model, Cmd.none )


view : Model -> Html Msg
view model =
    text "Ciao Mondo"
