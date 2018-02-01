module Data exposing (..)

import Http exposing (..)


type alias Model =
    { formData : FormData
    , stuff : String
    , tournamentSerieses : List TournamentSeries
    , userId : String
    , users : List User
    }


type alias FormData =
    { user : UserData
    , tournament : TournamentData
    , tournamentSeries : TournamentSeriesData
    , stakingContract : StakingContractData
    }


type alias UserData =
    { email : String
    , name : String
    }


type alias TournamentData =
    { feeInCents : Int
    , name : String
    }


type alias StakingContractData =
    { halfPercentsSold : Int
    , rate : Float
    , stakerId : String
    }


type alias TournamentSeriesData =
    { city : String
    , name : String
    }


type Msg
    = CreateNewStakingContract TournamentId
    | CreateNewTournament SeriesId
    | CreateNewTournamentSeries
    | CreateNewUser
    | SetFormData Specifics String
    | UpdateTournamentSeriesesShow (Result Http.Error (List TournamentSeries))
    | UpdateUsersShown (Result Http.Error (List User))


type Specifics
    = SettUser UserFormData
    | SettTournament TournamentFormData
    | SettTournamentSeries TournamentSeriesFormData
    | SettStakingContract StakingContractFormData


type UserFormData
    = Email
    | Nome


type TournamentFormData
    = FeeInCents
    | TournamentName


type TournamentSeriesFormData
    = City
    | SeriesName


type StakingContractFormData
    = HalfPercentsSold
    | Rate
    | StakerId


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
