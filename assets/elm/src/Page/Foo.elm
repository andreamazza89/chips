module Page.Foo exposing (Model, Msg, initialModel, view)

import Html exposing (..)
import Html.Attributes exposing (..)


type alias Model =
    { fooData : Int }


type Msg
    = SetRoute


initialModel : Model
initialModel =
    Model 42


view : Model -> Html Msg
view model =
    div []
        [ h3 [] [ text "Foo yolo" ]
        , a [ href "#/ciao" ] [ text "back to reality" ]
        ]
