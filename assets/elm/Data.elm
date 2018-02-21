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
    { result : ResultData
    , stakingContract : StakingContractData
    , tournament : TournamentData
    , tournamentSeries : TournamentSeriesData
    , user : UserData
    }


type alias ResultData =
    { prize : Int }


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
    = CreateNewResult TournamentId PlayerId
    | CreateNewStakingContract TournamentId
    | CreateNewTournament SeriesId
    | CreateNewTournamentSeries
    | CreateNewUser
    | SetFormData Specifics String
    | UpdateTournamentSeriesesShow (Result Http.Error (List TournamentSeries))
    | UpdateUsersShown (Result Http.Error (List User))


type Specifics
    = SettResult ResultFormData
    | SettStakingContract StakingContractFormData
    | SettTournament TournamentFormData
    | SettTournamentSeries TournamentSeriesFormData
    | SettUser UserFormData


type ResultFormData
    = Prize


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
    { id : TournamentId
    , fee_in_cents : Int
    , name : String
    , result : Maybe Int
    , stakingContracts : List StakingContract
    }


type alias TournamentId =
    String


type alias PlayerId =
    String
