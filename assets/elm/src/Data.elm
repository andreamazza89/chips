module Data exposing (..)

import Http exposing (..)
import Page.Page exposing (Page(..))
import Page.Authentication as Auth
import Router exposing (Route(..))
import User exposing (AuthenticatedUser)


type alias Model =
    { formData : FormData
    , moneis : List Moneis
    , stuff : String
    , tournamentSerieses : List TournamentSeries
    , userId : String
    , users : List User
    , currentPage : Page
    , authenticatedUser : Maybe AuthenticatedUser
    }


type alias Moneis =
    { user : User, balance : Float }


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
    { percentsSold : Float
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
    | AuthenticationMsg Auth.Msg
    | SetFormData Specifics String
    | SetRoute Route
    | UpdateMoneisShown (Result Http.Error (List Moneis))
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
    = PercentsSold
    | Rate
    | StakerId


type alias StakingContract =
    { rate : Float
    , staker : Staker
    , percentsSold : Float
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


type alias PlayerId =
    String


type alias TournamentId =
    String
