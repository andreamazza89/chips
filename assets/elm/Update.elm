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

        SetHalfPercents halfPercentsSold ->
            case (String.toInt halfPercentsSold) of
                Ok percent ->
                    ( { model | halfPercentsSold = percent }, Cmd.none )

                Err message ->
                    ( { model | stuff = message }, Cmd.none )

        SetNewTournamentName name ->
            ( { model | newTournamentName = name }, Cmd.none )

        SetNewTournamentFeeInCents fee ->
            case (String.toInt fee) of
                Ok parsedFee ->
                    ( { model | newTournamentFeeInCents = parsedFee }, Cmd.none )

                Err message ->
                    ( { model | stuff = message }, Cmd.none )

        SetNewTournamentSeriesCity city ->
            ( { model | newTournamentSeriesCity = city }, Cmd.none )

        SetNewTournamentSeriesName name ->
            ( { model | newTournamentSeriesName = name }, Cmd.none )

        SetRate rate ->
            case (String.toFloat rate) of
                Ok rate ->
                    ( { model | rate = rate }, Cmd.none )

                Err message ->
                    ( { model | stuff = message }, Cmd.none )

        SetStakerId stakerId ->
            ( { model | stakerId = stakerId }, Cmd.none )

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
