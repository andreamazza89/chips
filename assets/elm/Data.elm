module Data exposing (..)

import Http exposing (..)


type alias Model =
    { userId : String
    , formData : FormData
    , newTournamentSeriesCity : String
    , newTournamentSeriesName : String
    , stuff : String
    , tournamentSerieses : List TournamentSeries
    , users : List User
    }


type alias FormData =
    { user : UserData
    , tournament : TournamentData
    , stakingContract : StakingContractData
    }


type alias UserData =
    { name : String
    , email : String
    }


type alias TournamentData =
    { name : String
    , feeInCents : Int
    }


type alias StakingContractData =
    { halfPercentsSold : Int
    , rate : Float
    , stakerId : String
    }


type Specifics
    = SettUser UserFormData
    | SettTournament TournamentFormData
    | SettStakingContract StakingContractFormData


type UserFormData
    = Nome
    | Email


type TournamentFormData
    = Name
    | FeeInCents


type StakingContractFormData
    = HalfPercentsSold
    | Rate
    | StakerId


type Msg
    = CreateNewStakingContract TournamentId
    | CreateNewTournament SeriesId
    | CreateNewTournamentSeries
    | CreateNewUser
    | SetFormData Specifics String
    | SetNewTournamentSeriesCity String
    | SetNewTournamentSeriesName String
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
