module View.View exposing (view)

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Data exposing (..)


view : Model -> Html Msg
view model =
    div []
        [ text model.stuff
        , users model
        , newSeries
        , allSerieses model
        ]


users : Model -> Html Msg
users model =
    div [ class "users-container" ]
        [ h3 [] [ text "Users in the system" ]
        , showUsers model.users
        , newUser
        ]


showUsers : List User -> Html Msg
showUsers users =
    ul []
        (List.map
            (\user -> li [] [ text ("(id: " ++ user.id ++ ") " ++ user.name) ])
            users
        )


newUser : Html Msg
newUser =
    div []
        [ text "Create new user below"
        , Html.form
            [ onSubmit (CreateNewUser) ]
            [ label []
                [ text "User name"
                , input
                    [ name "user-name"
                    , onInput <| SetFormData (SettUser Nome)
                    ]
                    []
                ]
            , label []
                [ text "Email"
                , input
                    [ name "email"
                    , onInput <| SetFormData (SettUser Email)
                    ]
                    []
                ]
            , button [] [ text "submit" ]
            ]
        ]


newSeries : Html Msg
newSeries =
    div [ class "new-series-container" ]
        [ text "Create new tournament series"
        , Html.form
            [ onSubmit (CreateNewTournamentSeries) ]
            [ label []
                [ text "city"
                , input
                    [ name "city"
                    , onInput <| SetFormData (SettTournamentSeries City)
                    ]
                    []
                ]
            , label []
                [ text "name"
                , input
                    [ name "name"
                    , onInput <| SetFormData (SettTournamentSeries SeriesName)
                    ]
                    []
                ]
            , button [] [ text "submit" ]
            ]
        ]


allSerieses : Model -> Html Msg
allSerieses model =
    div [] (List.map viewSeries model.tournamentSerieses)


viewSeries : TournamentSeries -> Html Msg
viewSeries series =
    div [ class "tournament-series" ]
        [ h3 [] [ text series.name ]
        , viewTournaments series
        ]


viewTournaments : TournamentSeries -> Html Msg
viewTournaments series =
    div []
        [ newTournament series
        , div [ class "tournaments-wrapper" ] (List.map viewTournament series.tournaments)
        ]


newTournament : TournamentSeries -> Html Msg
newTournament series =
    div []
        [ text ("Add a new tournament in this series")
        , Html.form
            [ onSubmit (CreateNewTournament series.id) ]
            [ label []
                [ text "name"
                , input
                    [ name "name"
                    , onInput <| SetFormData (SettTournament TournamentName)
                    ]
                    []
                ]
            , label []
                [ text "fee in cents"
                , input
                    [ name "fee in cents"
                    , onInput <| SetFormData (SettTournament FeeInCents)
                    ]
                    []
                ]
            , button [] [ text "submit" ]
            ]
        ]


viewTournament : Tournament -> Html Msg
viewTournament tournament =
    div [ class "tournament" ]
        [ h4 [] [ text tournament.name ]
        , ul [] (List.map viewStakingContract tournament.stakingContracts)
        , newStakingContract tournament
        , br [] []
        ]


viewStakingContract : StakingContract -> Html Msg
viewStakingContract stakingContract =
    li []
        [ text
            (stakingContract.staker.name
                ++ " | rate: "
                ++ toString stakingContract.rate
                ++ " | half_percents_sold: "
                ++ toString stakingContract.halfPercentsSold
            )
        ]


newStakingContract : Tournament -> Html Msg
newStakingContract tournament =
    div []
        [ text "add a new staker for this tournament below"
        , newStakerForm tournament
        ]


newStakerForm : Tournament -> Html Msg
newStakerForm tournament =
    div []
        [ Html.form
            [ onSubmit (CreateNewStakingContract tournament.id) ]
            [ label []
                [ text "Staker id"
                , input
                    [ name "staker-id"
                    , onInput <| SetFormData (SettStakingContract StakerId)
                    ]
                    []
                ]
            , label []
                [ text "half percents sold"
                , input
                    [ name "half-percents-sold"
                    , onInput <| SetFormData (SettStakingContract HalfPercentsSold)
                    ]
                    []
                ]
            , label []
                [ text "rate"
                , input
                    [ name "rate"
                    , onInput <| SetFormData (SettStakingContract Rate)
                    ]
                    []
                ]
            , button [] [ text "submit" ]
            ]
        ]
