module Update exposing (update)

import Http exposing (..)
import Data exposing (..)
import Queries exposing (..)


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        CreateNewStakingContract tournamentId ->
            ( model, createNewStakingContract model tournamentId )

        SetFormData formSpecifics userInput ->
            handleFormInput model formSpecifics userInput

        CreateNewUser ->
            ( model, createUser model.formData.user.name model.formData.user.email )

        CreateNewTournament seriesId ->
            ( model, createTournament model seriesId )

        CreateNewTournamentSeries ->
            ( model, createTournamentSeries model )

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


handleFormInput : Model -> Specifics -> String -> ( Model, Cmd Msg )
handleFormInput model formSpecifics userInput =
    case formSpecifics of
        SettUser Nome ->
            let
                existingUserData =
                    model.formData.user

                newUserData =
                    { existingUserData | name = userInput }

                existingFormData =
                    model.formData

                newFormData =
                    { existingFormData | user = newUserData }
            in
                ( { model | formData = newFormData }, Cmd.none )

        SettUser Email ->
            let
                existingUserData =
                    model.formData.user

                newUserData =
                    { existingUserData | email = userInput }

                existingFormData =
                    model.formData

                newFormData =
                    { existingFormData | user = newUserData }
            in
                ( { model | formData = newFormData }, Cmd.none )

        SettTournament TournamentName ->
            let
                existingTournamentData =
                    model.formData.tournament

                newTournamentData =
                    { existingTournamentData | name = userInput }

                existingFormData =
                    model.formData

                newFormData =
                    { existingFormData | tournament = newTournamentData }
            in
                ( { model | formData = newFormData }, Cmd.none )

        SettTournament FeeInCents ->
            case (String.toInt userInput) of
                Ok fee ->
                    let
                        existingTournamentData =
                            model.formData.tournament

                        newTournamentData =
                            { existingTournamentData | feeInCents = fee }

                        existingFormData =
                            model.formData

                        newFormData =
                            { existingFormData | tournament = newTournamentData }
                    in
                        ( { model | formData = newFormData }, Cmd.none )

                Err message ->
                    ( { model | stuff = message }, Cmd.none )

        SettTournamentSeries City ->
            let
                existingTournamentSeriesData =
                    model.formData.tournamentSeries

                newTournamentSeriesData =
                    { existingTournamentSeriesData | city = userInput }

                existingFormData =
                    model.formData

                newFormData =
                    { existingFormData | tournamentSeries = newTournamentSeriesData }
            in
                ( { model | formData = newFormData }, Cmd.none )

        SettTournamentSeries SeriesName ->
            let
                existingTournamentSeriesData =
                    model.formData.tournamentSeries

                newTournamentSeriesData =
                    { existingTournamentSeriesData | name = userInput }

                existingFormData =
                    model.formData

                newFormData =
                    { existingFormData | tournamentSeries = newTournamentSeriesData }
            in
                ( { model | formData = newFormData }, Cmd.none )

        SettStakingContract HalfPercentsSold ->
            case (String.toInt userInput) of
                Ok percentSold ->
                    let
                        existingStakingContractData =
                            model.formData.stakingContract

                        newStakingContractData =
                            { existingStakingContractData | halfPercentsSold = percentSold }

                        existingFormData =
                            model.formData

                        newFormData =
                            { existingFormData | stakingContract = newStakingContractData }
                    in
                        ( { model | formData = newFormData }, Cmd.none )

                Err message ->
                    ( { model | stuff = message }, Cmd.none )

        SettStakingContract Rate ->
            case (String.toFloat userInput) of
                Ok rate ->
                    let
                        existingStakingContractData =
                            model.formData.stakingContract

                        newStakingContractData =
                            { existingStakingContractData | rate = rate }

                        existingFormData =
                            model.formData

                        newFormData =
                            { existingFormData | stakingContract = newStakingContractData }
                    in
                        ( { model | formData = newFormData }, Cmd.none )

                Err message ->
                    ( { model | stuff = message }, Cmd.none )

        SettStakingContract StakerId ->
            let
                existingStakingContractData =
                    model.formData.stakingContract

                newStakingContractData =
                    { existingStakingContractData | stakerId = userInput }

                existingFormData =
                    model.formData

                newFormData =
                    { existingFormData | stakingContract = newStakingContractData }
            in
                ( { model | formData = newFormData }, Cmd.none )
