module Main exposing (..)

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Http exposing (..)
import Json.Decode exposing (list, field, string)
import Json.Encode exposing (encode, object)


type alias Model =
    { userName : String
    , email : String
    , stuff : String
    }


type Msg
    = Nada
    | CreateNewUser
    | NewStuff (Result Http.Error (List String))
    | SetEmail String
    | SetUserName String


main : Program Never Model Msg
main =
    Html.program
        { init = ( { userName = "", email = "", stuff = "empty stuff" }, Cmd.none )
        , update = update
        , subscriptions = (always Sub.none)
        , view = view
        }


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        Nada ->
            ( model, Cmd.none )

        NewStuff (Ok newStuff) ->
            case List.head (newStuff) of
                Just name ->
                    ( { model | stuff = name }, Cmd.none )

                Nothing ->
                    ( { model | stuff = "nothing found" }, Cmd.none )

        NewStuff (Err (BadPayload message response)) ->
            ( model, Cmd.none )

        NewStuff (Err _) ->
            ( { model | stuff = "error fetching new stuff" }, Cmd.none )

        SetUserName userName ->
            ( { model | userName = userName }, Cmd.none )

        SetEmail email ->
            ( { model | email = email }, Cmd.none )

        CreateNewUser ->
            ( model, getStuff )


getStuff : Cmd Msg
getStuff =
    Http.send NewStuff <| Http.post "http://localhost:4000/api" requestBody usersDecoder


requestBody : Body
requestBody =
    Http.jsonBody
        (Json.Encode.object
            [ ( "query", Json.Encode.string "query { users { name } }" ) ]
        )


type alias User =
    String


usersDecoder : Json.Decode.Decoder (List User)
usersDecoder =
    field "data" <|
        field "users" <|
            Json.Decode.list userDecoder


userDecoder : Json.Decode.Decoder User
userDecoder =
    field "name" string


view : Model -> Html Msg
view model =
    div []
        [ Html.form
            [ onSubmit CreateNewUser ]
            [ label []
                [ text "User name"
                , input
                    [ placeholder "sandro"
                    , name "user-name"
                    , onInput <| SetUserName
                    ]
                    []
                ]
            , label []
                [ text "Email"
                , input
                    [ placeholder "email"
                    , name "email"
                    , onInput <| SetEmail
                    ]
                    []
                ]
            , button [] [ text "submit" ]
            ]
        , text model.stuff
        ]
