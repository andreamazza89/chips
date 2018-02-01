module Queries exposing (..)

import Http exposing (..)
import Json.Decode exposing (list, field, float, map, map2, map3, map4, string, int)
import Json.Encode exposing (encode, object)
import Data exposing (..)


createTournamentSeries : Model -> Cmd Msg
createTournamentSeries model =
    Http.send UpdateTournamentSeriesesShow <|
        Http.post
            "http://localhost:4000/api"
            (newTournamentSeriesRequestBody model.formData.tournamentSeries.city model.formData.tournamentSeries.name)
            (graphQlDecoder "createTournamentSeries" (list tournamentSeriesDecoder))


newTournamentSeriesRequestBody : String -> String -> Body
newTournamentSeriesRequestBody city name =
    Http.jsonBody
        (Json.Encode.object
            [ ( "query"
              , Json.Encode.string
                    ("mutation { createTournamentSeries(city: \""
                        ++ city
                        ++ "\", name: \""
                        ++ name
                        ++ "\")"
                        ++ "{ id, name, city, tournaments {id, name, stakingContracts { halfPercentsSold, staker { name }, rate }} }"
                        ++ "}"
                    )
              )
            ]
        )


createNewStakingContract : Model -> TournamentId -> Cmd Msg
createNewStakingContract model tournamentId =
    Http.send UpdateTournamentSeriesesShow <|
        Http.post
            "http://localhost:4000/api"
            (newStakeContractRequestBody
                model.formData.stakingContract.stakerId
                model.formData.stakingContract.halfPercentsSold
                model.userId
                model.formData.stakingContract.rate
                tournamentId
            )
            (graphQlDecoder "createStakingContract" (list tournamentSeriesDecoder))


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
                        ++ "{ id, name, city, tournaments {id, name, stakingContracts { halfPercentsSold, staker { name }, rate }} }"
                        ++ "}"
                    )
              )
            ]
        )


createTournament : Model -> SeriesId -> Cmd Msg
createTournament model seriesId =
    Http.send UpdateTournamentSeriesesShow <|
        Http.post
            "http://localhost:4000/api"
            (newTournamentRequestBody model.formData.tournament.name model.formData.tournament.feeInCents seriesId)
            (graphQlDecoder "createTournament" (list tournamentSeriesDecoder))


newTournamentRequestBody : String -> Int -> SeriesId -> Body
newTournamentRequestBody name feeInCents seriesId =
    Http.jsonBody
        (Json.Encode.object
            [ ( "query"
              , Json.Encode.string
                    ("mutation { createTournament(name: \""
                        ++ name
                        ++ "\", feeInCents: "
                        ++ toString feeInCents
                        ++ ", tournamentSeriesId: \""
                        ++ seriesId
                        ++ "\")"
                        ++ "{ id, name, city, tournaments {id, name, stakingContracts { halfPercentsSold, staker { name }, rate }} }"
                        ++ "}"
                    )
              )
            ]
        )


fetchUsers : Cmd Msg
fetchUsers =
    Http.send UpdateUsersShown <|
        Http.post
            "http://localhost:4000/api"
            usersRequestBody
            (graphQlDecoder "users" (list userDecoder))


usersRequestBody : Body
usersRequestBody =
    Http.jsonBody
        (Json.Encode.object
            [ ( "query", Json.Encode.string "query { users { name, id } }" ) ]
        )


fetchSerieses : Cmd Msg
fetchSerieses =
    Http.send UpdateTournamentSeriesesShow <|
        Http.post
            "http://localhost:4000/api"
            tournamentSeriesesRequestBody
            (graphQlDecoder "tournamentSerieses" (list tournamentSeriesDecoder))


tournamentSeriesesRequestBody : Body
tournamentSeriesesRequestBody =
    Http.jsonBody
        (Json.Encode.object
            [ ( "query"
              , Json.Encode.string
                    ("query { tournamentSerieses {"
                        ++ "city,"
                        ++ "id,"
                        ++ "name,"
                        ++ " tournaments { name, id, stakingContracts { staker { name }, rate, halfPercentsSold } } } }"
                    )
              )
            ]
        )


createUser : String -> String -> Cmd Msg
createUser name email =
    Http.send UpdateUsersShown <|
        Http.post
            "http://localhost:4000/api"
            (createUserRequestBody name email)
            (graphQlDecoder "createUser" (list userDecoder))


createUserRequestBody : String -> String -> Body
createUserRequestBody name email =
    Http.jsonBody
        (Json.Encode.object
            [ ( "query", Json.Encode.string ("mutation createUser { createUser(name: \"" ++ name ++ "\", email: \"" ++ email ++ "\") { id, name } }") ) ]
        )


graphQlDecoder : String -> Json.Decode.Decoder a -> Json.Decode.Decoder a
graphQlDecoder fieldName decoder =
    field "data" <|
        field fieldName <|
            decoder


userDecoder : Json.Decode.Decoder User
userDecoder =
    map2 User
        (field "id" string)
        (field "name" string)


tournamentSeriesDecoder : Json.Decode.Decoder TournamentSeries
tournamentSeriesDecoder =
    map4 TournamentSeries
        (field "city" string)
        (field "id" string)
        (field "name" string)
        (field "tournaments" (list tournamentDecoder))


tournamentDecoder : Json.Decode.Decoder Tournament
tournamentDecoder =
    map3 Tournament
        (field "name" string)
        (field "id" string)
        (field "stakingContracts" (list stakingContractDecoder))


stakingContractDecoder : Json.Decode.Decoder StakingContract
stakingContractDecoder =
    map3 StakingContract
        (field "rate" float)
        (field "staker" stakerDecoder)
        (field "halfPercentsSold" int)


stakerDecoder : Json.Decode.Decoder Staker
stakerDecoder =
    map Staker
        (field "name" string)
