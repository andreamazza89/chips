module Main exposing (..)

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Http exposing (..)
import Json.Decode exposing (list, field, float, map2, map3, string, int)
import Json.Encode exposing (encode, object)


type alias Model =
    { userName : String
    , userId : String
    , email : String
    , halfPercentsSold : Int
    , rate : Float
    , stakerId : String
    , stuff : String
    , tournaments : List Tournament
    }


type Msg
    = CreateNewStakingContract TournamentId
    | CreateNewUser
    | Nada String
    | NewStuff (Result Http.Error (List String))
    | SetHalfPercents String
    | SetRate String
    | SetStakerId String
    | SetEmail String
    | SetUserName String
    | UpdateTournamentsShown (Result Http.Error (List Tournament))


initialState : Model
initialState =
    { userName = ""
    , userId = "1"
    , email = ""
    , halfPercentsSold = 0
    , rate = 0
    , stakerId = "0"
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
        CreateNewStakingContract tournamentId ->
            ( model, createNewStakingContract model tournamentId )

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

        SetHalfPercents halfPercentsSold ->
            case (String.toInt halfPercentsSold) of
                Ok percent ->
                    ( { model | halfPercentsSold = percent }, Cmd.none )

                Err message ->
                    ( { model | stuff = message }, Cmd.none )

        SetUserName userName ->
            ( { model | userName = userName }, Cmd.none )

        SetEmail email ->
            ( { model | email = email }, Cmd.none )

        SetRate rate ->
            case (String.toFloat rate) of
                Ok rate ->
                    ( { model | rate = rate }, Cmd.none )

                Err message ->
                    ( { model | stuff = message }, Cmd.none )

        SetStakerId stakerId ->
            ( { model | stakerId = stakerId }, Cmd.none )

        CreateNewUser ->
            ( model, getStuff )

        UpdateTournamentsShown (Ok newStuff) ->
            ( { model | tournaments = newStuff }, Cmd.none )

        UpdateTournamentsShown (Err (BadPayload message response)) ->
            ( { model | stuff = message }, Cmd.none )

        UpdateTournamentsShown (Err _) ->
            ( { model | stuff = "error fetching tournaments" }, Cmd.none )


createNewStakingContract : Model -> TournamentId -> Cmd Msg
createNewStakingContract model tournamentId =
    Http.send UpdateTournamentsShown <|
        Http.post
            "http://localhost:4000/api"
            (newStakeContractRequestBody model.stakerId model.halfPercentsSold model.userId model.rate tournamentId)
            tournamentMutationDecoder


newStakeContractRequestBody : String -> Int -> String -> Float -> String -> Body
newStakeContractRequestBody stakerId halfPercents userId rate tournamentId =
    Http.jsonBody
        (Json.Encode.object
            [ ( "query"
              , Json.Encode.string
                    ("mutation { createStakingContract(halfPercentsSold: "
                        ++ toString halfPercents
                        ++ ", rate: "
                        ++ toString rate
                        ++ ", stakerId: "
                        ++ stakerId
                        ++ ", tournamentId: "
                        ++ tournamentId
                        ++ ", userId: "
                        ++ userId
                        ++ ")"
                        ++ "{ name, id, stakingContracts { staker { name }, rate } }"
                        ++ "}"
                    )
              )
            ]
        )


fetchTournaments : Cmd Msg
fetchTournaments =
    Http.send UpdateTournamentsShown <| Http.post "http://localhost:4000/api" tournamentsRequestBody tournamentsDecoder


tournamentsRequestBody : Body
tournamentsRequestBody =
    Http.jsonBody
        (Json.Encode.object
            [ ( "query", Json.Encode.string "query { tournaments { name, id, stakingContracts { staker { name }, rate } } }" ) ]
        )


tournamentMutationDecoder : Json.Decode.Decoder (List Tournament)
tournamentMutationDecoder =
    field "data" <|
        field "createStakingContract" <|
            Json.Decode.list tournamentDecoder


tournamentsDecoder : Json.Decode.Decoder (List Tournament)
tournamentsDecoder =
    field "data" <|
        field "tournaments" <|
            Json.Decode.list tournamentDecoder


tournamentDecoder : Json.Decode.Decoder Tournament
tournamentDecoder =
    map3 Tournament
        (field "name" string)
        (field "id" string)
        (field "stakingContracts" (Json.Decode.list stakingContractDecoder))


stakingContractDecoder : Json.Decode.Decoder StakingContract
stakingContractDecoder =
    map2 StakingContract
        (field "rate" float)
        (field "staker" stakerDecoder)


stakerDecoder : Json.Decode.Decoder Staker
stakerDecoder =
    Json.Decode.map Staker
        (field "name" string)


type alias StakingContract =
    { rate : Float
    , staker : Staker
    }


type alias Staker =
    { name : String }


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
    , id : TournamentId
    , stakingContracts : List StakingContract
    }


type alias TournamentId =
    String


view : Model -> Html Msg
view model =
    div []
        [ text model.stuff
        , allTournaments model
        ]


allTournaments : Model -> Html Msg
allTournaments model =
    div []
        [ viewTournaments model.tournaments ]


viewTournaments : List Tournament -> Html Msg
viewTournaments tournaments =
    div []
        [ h3 [] [ text "Tournaments" ]
        , div [] (List.map viewTournament tournaments)
        ]


viewTournament : Tournament -> Html Msg
viewTournament tournament =
    div []
        [ h4 [] [ text tournament.name ]
        , ul [] (List.map viewStakingContract tournament.stakingContracts)
        , newStakingContract tournament
        , br [] []
        ]


viewStakingContract : StakingContract -> Html Msg
viewStakingContract stakingContract =
    li [] [ text (stakingContract.staker.name ++ " " ++ toString stakingContract.rate) ]


newStakingContract : Tournament -> Html Msg
newStakingContract tournament =
    div []
        [ text "add a new staker for this tournament below"
        , newStakerForm tournament
        ]


newStakerForm : Tournament -> Html Msg
newStakerForm tournament =
    div []
        [ Html.form
            [ onSubmit (CreateNewStakingContract tournament.id) ]
            [ label []
                [ text "Staker id"
                , input
                    [ name "staker-id"
                    , onInput <| SetStakerId
                    ]
                    []
                ]
            , label []
                [ text "half percents sold"
                , input
                    [ name "half-percents-sold"
                    , onInput <| SetHalfPercents
                    ]
                    []
                , label []
                    [ text "rate"
                    , input
                        [ name "rate"
                        , onInput <| SetRate
                        ]
                        []
                    ]
                ]
            , button [] [ text "submit" ]
            ]
        ]
