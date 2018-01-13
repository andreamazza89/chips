module Main exposing (..)

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Http exposing (..)
import Json.Decode exposing (list, field, map2, string)
import Json.Encode exposing (encode, object)


type alias Model =
    { userName : String
    , email : String
    , stuff : String
    , tournaments : List Tournament
    }


type Msg
    = CreateNewUser
    | Nada String
    | NewStuff (Result Http.Error (List String))
    | SetEmail String
    | SetUserName String
    | UpdateTournamentsShown (Result Http.Error (List Tournament))


initialState : Model
initialState =
    { userName = ""
    , email = ""
    , stuff = "empty stuff"
    , tournaments = []
    }


main : Program Never Model Msg
main =
    Html.program
        { init = ( initialState, fetchTournaments )
        , update = update
        , subscriptions = (always Sub.none)
        , view = view
        }


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        Nada confirm ->
            ( { model | stuff = confirm }, Cmd.none )

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

        UpdateTournamentsShown (Ok newStuff) ->
            ( { model | tournaments = newStuff }, Cmd.none )

        UpdateTournamentsShown (Err (BadPayload message response)) ->
            ( { model | stuff = message }, Cmd.none )

        UpdateTournamentsShown (Err _) ->
            ( { model | stuff = "error fetching tournaments" }, Cmd.none )


fetchTournaments : Cmd Msg
fetchTournaments =
    Http.send UpdateTournamentsShown <| Http.post "http://localhost:4000/api" tournamentsRequestBody tournamentsDecoder


tournamentsRequestBody : Body
tournamentsRequestBody =
    Http.jsonBody
        (Json.Encode.object
            [ ( "query", Json.Encode.string "query { tournaments { name, id } }" ) ]
        )


tournamentsDecoder : Json.Decode.Decoder (List Tournament)
tournamentsDecoder =
    field "data" <|
        field "tournaments" <|
            Json.Decode.list tournamentDecoder


tournamentDecoder : Json.Decode.Decoder Tournament
tournamentDecoder =
    map2 Tournament
        (field "name" string)
        (field "id" string)


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


type alias Tournament =
    { name : String
    , id : String
    }


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
        , allTournaments model
        ]


allTournaments : Model -> Html Msg
allTournaments model =
    div []
        [ viewTournaments model.tournaments ]


viewTournaments : List Tournament -> Html Msg
viewTournaments tournaments =
    div []
        [ h3 [] [ text "tournaments available" ]
        , ul [] (List.map viewTournament tournaments)
        ]


viewTournament : Tournament -> Html Msg
viewTournament tournament =
    li [] [ text (tournament.name ++ " id: " ++ tournament.id) ]
