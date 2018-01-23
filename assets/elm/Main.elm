module Main exposing (..)

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Http exposing (..)
import Json.Decode exposing (list, field, float, map2, map3, map4, string, int)
import Json.Encode exposing (encode, object)
import Platform.Cmd exposing (batch)


type alias Model =
    { userName : String
    , userId : String
    , email : String
    , halfPercentsSold : Int
    , rate : Float
    , stakerId : String
    , stuff : String
    , tournaments : List Tournament
    , tournamentSerieses : List TournamentSeries
    , users : List User
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
    | UpdateTournamentSeriesesShow (Result Http.Error (List TournamentSeries))
    | UpdateUsersShown (Result Http.Error (List User))


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
    , tournamentSerieses = []
    , users = []
    }


main : Program Never Model Msg
main =
    Html.program
        { init = ( initialState, batch [ fetchSerieses, fetchUsers ] )
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
            ( model, createUser model.userName model.email )

        UpdateTournamentsShown (Ok newStuff) ->
            ( { model | tournaments = newStuff }, Cmd.none )

        UpdateTournamentsShown (Err (BadPayload message response)) ->
            ( { model | stuff = message }, Cmd.none )

        UpdateTournamentsShown (Err _) ->
            ( { model | stuff = "error fetching tournaments" }, Cmd.none )

        UpdateTournamentSeriesesShow (Ok serieses) ->
            ( { model | tournamentSerieses = serieses }, Cmd.none )

        UpdateTournamentSeriesesShow (Err (BadPayload message response)) ->
            ( { model | stuff = message }, Cmd.none )

        UpdateTournamentSeriesesShow (Err _) ->
            ( { model | stuff = "error fetching tournaments" }, Cmd.none )

        UpdateUsersShown (Ok newUsers) ->
            ( { model | users = newUsers }, Cmd.none )

        UpdateUsersShown (Err (BadPayload message response)) ->
            ( { model | stuff = message }, Cmd.none )

        UpdateUsersShown (Err _) ->
            ( { model | stuff = "error fetching users" }, Cmd.none )


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
                        ++ ", playerId: "
                        ++ userId
                        ++ ")"
                        ++ "{ name, id, stakingContracts { staker { name }, rate, halfPercentsSold } }"
                        ++ "}"
                    )
              )
            ]
        )


fetchUsers : Cmd Msg
fetchUsers =
    Http.send UpdateUsersShown <| Http.post "http://localhost:4000/api" usersRequestBody usersDecoder


usersDecoder : Json.Decode.Decoder (List User)
usersDecoder =
    field "data" <|
        field "users" <|
            Json.Decode.list userDecoder


userDecoder : Json.Decode.Decoder User
userDecoder =
    map2 User
        (field "id" string)
        (field "name" string)


usersRequestBody : Body
usersRequestBody =
    Http.jsonBody
        (Json.Encode.object
            [ ( "query", Json.Encode.string "query { users { name, id } }" ) ]
        )


fetchSerieses : Cmd Msg
fetchSerieses =
    Http.send UpdateTournamentSeriesesShow <| Http.post "http://localhost:4000/api" tournamentSeriesesRequestBody tournamentSeriesesDecoder


tournamentSeriesesRequestBody : Body
tournamentSeriesesRequestBody =
    Http.jsonBody
        (Json.Encode.object
            [ ( "query"
              , Json.Encode.string
                    ("query { tournamentSeries {"
                        ++ "city,"
                        ++ "id,"
                        ++ "name,"
                        ++ " tournaments { name, id, stakingContracts { staker { name }, rate, halfPercentsSold } } } }"
                    )
              )
            ]
        )


tournamentMutationDecoder : Json.Decode.Decoder (List Tournament)
tournamentMutationDecoder =
    field "data" <|
        field "createStakingContract" <|
            Json.Decode.list tournamentDecoder


tournamentSeriesesDecoder : Json.Decode.Decoder (List TournamentSeries)
tournamentSeriesesDecoder =
    field "data" <|
        field "tournamentSeries" <|
            Json.Decode.list tournamentSeriesDecoder


tournamentSeriesDecoder : Json.Decode.Decoder TournamentSeries
tournamentSeriesDecoder =
    map4 TournamentSeries
        (field "city" string)
        (field "id" string)
        (field "name" string)
        (field "tournaments" (Json.Decode.list tournamentDecoder))


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
    map3 StakingContract
        (field "rate" float)
        (field "staker" stakerDecoder)
        (field "halfPercentsSold" int)


stakerDecoder : Json.Decode.Decoder Staker
stakerDecoder =
    Json.Decode.map Staker
        (field "name" string)


type alias StakingContract =
    { rate : Float
    , staker : Staker
    , halfPercentsSold : Int
    }


type alias Staker =
    { name : String }


createUser : String -> String -> Cmd Msg
createUser name email =
    Http.send UpdateUsersShown <| Http.post "http://localhost:4000/api" (createUserRequestBody name email) usersMutationDecoder


createUserRequestBody : String -> String -> Body
createUserRequestBody name email =
    Http.jsonBody
        (Json.Encode.object
            [ ( "query", Json.Encode.string ("mutation createUser { createUser(name: \"" ++ name ++ "\", email: \"" ++ email ++ "\") { id, name } }") ) ]
        )


usersMutationDecoder : Json.Decode.Decoder (List User)
usersMutationDecoder =
    field "data" <|
        field "createUser" <|
            Json.Decode.list userDecoder


type alias User =
    { id : String
    , name : String
    }


type alias TournamentSeries =
    { city : String
    , id : String
    , name : String
    , tournaments : List Tournament
    }


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
        , users model
        , allSerieses model
        ]


allSerieses : Model -> Html Msg
allSerieses model =
    div [] (List.map viewSeries model.tournamentSerieses)


viewSeries : TournamentSeries -> Html Msg
viewSeries series =
    div []
        [ h3 [] [ text series.name ]
        , viewTournaments series
        ]


users : Model -> Html Msg
users model =
    div []
        [ h3 [] [ text "Users in the system" ]
        , showUsers model.users
        , newUser
        ]


showUsers : List User -> Html Msg
showUsers users =
    ul []
        (List.map
            (\user -> li [] [ text ("(id: " ++ user.id ++ ") " ++ user.name) ])
            users
        )


newUser : Html Msg
newUser =
    div []
        [ Html.form
            [ onSubmit (CreateNewUser) ]
            [ label []
                [ text "User name"
                , input
                    [ name "user-name"
                    , onInput <| SetUserName
                    ]
                    []
                ]
            , label []
                [ text "Email"
                , input
                    [ name "email"
                    , onInput <| SetEmail
                    ]
                    []
                ]
            , button [] [ text "submit" ]
            ]
        ]


viewTournaments : TournamentSeries -> Html Msg
viewTournaments series =
    div []
        [ h3 [] [ text "Your tournaments in this series" ]
        , div [] (List.map viewTournament series.tournaments)
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
    li []
        [ text
            (stakingContract.staker.name
                ++ " | rate: "
                ++ toString stakingContract.rate
                ++ " | half_percents_sold: "
                ++ toString stakingContract.halfPercentsSold
            )
        ]


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
