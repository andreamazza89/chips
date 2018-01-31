module Data exposing (..)

import Http exposing (..)


type alias Model =
    { userName : String
    , userId : String
    , email : String

    --, formData : FormData
    , halfPercentsSold : Int
    , newTournamentName : String
    , newTournamentFeeInCents : Int
    , newTournamentSeriesCity : String
    , newTournamentSeriesName : String
    , rate : Float
    , stakerId : String
    , stuff : String
    , tournaments : List Tournament
    , tournamentSerieses : List TournamentSeries
    , users : List User
    }


type alias FormData =
    { user : UserData }


type alias UserData =
    { name : Maybe String
    , email : Maybe String
    }


type Specifics
    = SettUser UserShit


type UserShit
    = Nome
    | Email


type Msg
    = CreateNewStakingContract TournamentId
    | CreateNewTournament SeriesId
    | CreateNewTournamentSeries
    | CreateNewUser
    | SetFormData Specifics String
    | SetHalfPercents String
    | SetRate String
    | SetStakerId String
    | SetEmail String
    | SetNewTournamentName String
    | SetNewTournamentFeeInCents String
    | SetNewTournamentSeriesCity String
    | SetNewTournamentSeriesName String
    | SetUserName String
    | UpdateTournamentSeriesesShow (Result Http.Error (List TournamentSeries))
    | UpdateUsersShown (Result Http.Error (List User))


type alias StakingContract =
    { rate : Float
    , staker : Staker
    , halfPercentsSold : Int
    }


type alias SeriesId =
    String


type alias Staker =
    { name : String }


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
