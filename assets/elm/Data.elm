module Data exposing (..)

import Http exposing (..)


type alias Model =
    { userName : String
    , userId : String
    , email : String
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


type Msg
    = CreateNewStakingContract TournamentId
    | CreateNewTournament SeriesId
    | CreateNewTournamentSeries
    | CreateNewUser
    | Nada String
    | NewStuff (Result Http.Error (List String))
    | SetHalfPercents String
    | SetRate String
    | SetStakerId String
    | SetEmail String
    | SetNewTournamentName String
    | SetNewTournamentFeeInCents String
    | SetNewTournamentSeriesCity String
    | SetNewTournamentSeriesName String
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
    , newTournamentName = ""
    , newTournamentFeeInCents = 0
    , newTournamentSeriesCity = ""
    , newTournamentSeriesName = ""
    , rate = 0
    , stakerId = "0"
    , stuff = "errors go here"
    , tournaments = []
    , tournamentSerieses = []
    , users = []
    }


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
