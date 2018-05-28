module Update exposing (update)

import Http exposing (..)
import Data exposing (..)
import Queries exposing (..)
import Page.Foo as Foo


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        CreateNewUser ->
            ( model, createUser model.formData.user.name model.formData.user.email )

        CreateNewResult tournamentId playerId ->
            ( model, createResult model tournamentId playerId )

        CreateNewStakingContract tournamentId ->
            ( model, createNewStakingContract model tournamentId )

        CreateNewTournament seriesId ->
            ( model, createTournament model seriesId )

        CreateNewTournamentSeries ->
            ( model, createTournamentSeries model )

        FooMsg _ ->
            ( model, Cmd.none )

        SetFormData formSpecifics userInput ->
            handleFormInput model formSpecifics userInput

        SetRoute GoToOldPage ->
            ( { model | currentPage = OldPage }, Cmd.none )

        SetRoute GoToNewPage ->
            ( { model | currentPage = Foo Foo.initialModel }, Cmd.none )

        UpdateMoneisShown result ->
            updateMoneisShown model result

        UpdateTournamentSeriesesShow result ->
            updateTournamentSeriesesShown model result

        UpdateUsersShown result ->
            updateUsersShown model result


updateMoneisShown : Model -> Result Http.Error (List Moneis) -> ( Model, Cmd Msg )
updateMoneisShown model result =
    case result of
        Ok new_moneis ->
            ( { model | moneis = new_moneis }, Cmd.none )

        Err (BadPayload message response) ->
            ( { model | stuff = message }, Cmd.none )

        Err _ ->
            ( { model | stuff = "error fetching moneis" }, Cmd.none )


updateTournamentSeriesesShown : Model -> Result Http.Error (List TournamentSeries) -> ( Model, Cmd Msg )
updateTournamentSeriesesShown model result =
    case result of
        Ok serieses ->
            ( { model | tournamentSerieses = serieses }, Cmd.none )

        Err (BadPayload message response) ->
            ( { model | stuff = message }, Cmd.none )

        Err _ ->
            ( { model | stuff = "error fetching tournaments" }, Cmd.none )


updateUsersShown : Model -> Result Http.Error (List User) -> ( Model, Cmd Msg )
updateUsersShown model result =
    case result of
        Ok newUsers ->
            ( { model | users = newUsers }, Cmd.none )

        Err (BadPayload message response) ->
            ( { model | stuff = message }, Cmd.none )

        Err _ ->
            ( { model | stuff = "error fetching users" }, Cmd.none )


handleFormInput : Model -> Specifics -> String -> ( Model, Cmd Msg )
handleFormInput model formSpecifics userInput =
    case formSpecifics of
        SettResult Prize ->
            case (String.toInt userInput) of
                Ok parsedPrize ->
                    let
                        existingResultData =
                            model.formData.result

                        newTournamentData =
                            { existingResultData | prize = parsedPrize }

                        existingFormData =
                            model.formData

                        newFormData =
                            { existingFormData | result = newTournamentData }
                    in
                        ( { model | formData = newFormData }, Cmd.none )

                Err message ->
                    ( { model | stuff = message }, Cmd.none )

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

        SettStakingContract PercentsSold ->
            case (String.toFloat userInput) of
                Ok sold ->
                    let
                        existingStakingContractData =
                            model.formData.stakingContract

                        newStakingContractData =
                            { existingStakingContractData | percentsSold = sold }

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
