module Page.MarketPlace exposing (Model, Msg, initialCmd, initialModel, view, update)

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Http
import Http exposing (..)
import Json.Decode exposing (..)
import Json.Encode exposing (..)
import User exposing (AuthenticatedUser)


type alias Model =
    { actionDollars : Int
    , actionMarkup : Float
    , formData : FormData
    , moneis : List Moneis
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
    { percentsSold : Float
    , rate : Float
    , stakerId : String
    }


type alias TournamentSeriesData =
    { city : String
    , name : String
    }


type Msg
    = CreateActionSale String
    | CreateNewResult TournamentId PlayerId
    | CreateNewStakingContract TournamentId
    | CreateNewTournament SeriesId
    | CreateNewTournamentSeries
    | CreateNewUser
    | SetFormData Specifics String
    | SetActionDollars String
    | SetActionMarkup String
    | UpdateMoneisShown (Result Http.Error (List Moneis))
    | UpdateTournamentSeriesesShow (Result Http.Error (List TournamentSeries))
    | UpdateUsersShown (Result Http.Error (List User))


type ExternalMsg
    = NoOp


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


type alias Moneis =
    { user : User, balance : Float }


initialModel : Model
initialModel =
    { actionDollars = 0
    , actionMarkup = 0
    , userId = "1"
    , formData = initialFormData
    , moneis = []
    , stuff = "errors go here"
    , tournamentSerieses = []
    , users = []
    }



-- need to change so that the main Update only hits this when there is a user


initialCmd : Maybe AuthenticatedUser -> Cmd Msg
initialCmd authenticatedUser =
    case authenticatedUser of
        Just user ->
            fetchSerieses user.token

        Nothing ->
            Cmd.none


fetchSerieses : String -> Cmd Msg
fetchSerieses token =
    Http.send UpdateTournamentSeriesesShow <|
        authenticatedRequest
            "/api"
            token
            tournamentSeriesesRequestBody
            (graphQlDecoder "tournamentSerieses" (Json.Decode.list tournamentSeriesDecoder))


tournamentSeriesesRequestBody : Body
tournamentSeriesesRequestBody =
    Http.jsonBody
        (Json.Encode.object
            [ ( "query"
              , Json.Encode.string
                    ("query { tournamentSerieses {"
                        ++ "city,"
                        ++ "id,"
                        ++ "name,"
                        ++ " tournaments { feeInCents, name, id, result, stakingContracts { staker { name }, rate, percentsSold } } } }"
                    )
              )
            ]
        )


initialFormData : FormData
initialFormData =
    { result = { prize = 0 }
    , stakingContract = { percentsSold = 0, rate = 0, stakerId = "" }
    , tournament = { name = "", feeInCents = 0 }
    , tournamentSeries = { city = "", name = "" }
    , user = { name = "", email = "" }
    }


update : Maybe AuthenticatedUser -> ( Model, Msg ) -> ( ( Model, Cmd Msg ), ExternalMsg )
update user ( model, msg ) =
    case msg of
        CreateActionSale tournamentId ->
            ( ( model, createActionSaleRequest model user tournamentId ), NoOp )

        CreateNewResult tournamentId playerId ->
            ( ( model, createResult model user tournamentId playerId ), NoOp )

        CreateNewStakingContract tournamentId ->
            ( ( model, createNewStakingContract model user tournamentId ), NoOp )

        CreateNewTournament seriesId ->
            ( ( model, createTournament model user seriesId ), NoOp )

        CreateNewTournamentSeries ->
            ( ( model, createTournamentSeries model user ), NoOp )

        SetActionDollars input ->
            case String.toInt input of
                Ok dollars ->
                    ( ( { model | actionDollars = dollars }, Cmd.none ), NoOp )

                Err msg ->
                    ( ( { model | stuff = msg }, Cmd.none ), NoOp )

        SetActionMarkup input ->
            case String.toFloat input of
                Ok markup ->
                    ( ( { model | actionMarkup = markup }, Cmd.none ), NoOp )

                Err msg ->
                    ( ( { model | stuff = msg }, Cmd.none ), NoOp )

        SetFormData formSpecifics userInput ->
            ( handleFormInput model formSpecifics userInput, NoOp )

        UpdateTournamentSeriesesShow result ->
            ( updateTournamentSeriesesShown model result, NoOp )

        -- remove this catchall once cleaned up the old stuff
        _ ->
            ( ( model, Cmd.none ), NoOp )


createActionSaleRequest : Model -> Maybe AuthenticatedUser -> String -> Cmd Msg
createActionSaleRequest model authenticatedUser tournamentId =
    case authenticatedUser of
        Just user ->
            Http.send UpdateTournamentSeriesesShow <|
                authenticatedRequest
                    "/api"
                    user.token
                    (createActionSaleRequestBody user.userName tournamentId model.actionDollars model.actionMarkup)
                    (graphQlDecoder "createResult" (Json.Decode.list tournamentSeriesDecoder))

        Nothing ->
            Cmd.none


createActionSaleRequestBody : String -> String -> Int -> Float -> Body
createActionSaleRequestBody userName tournamentId dollars markup =
    Http.jsonBody
        (Json.Encode.object
            [ ( "query"
              , Json.Encode.string
                    ("mutation { createActionSale(tournamentId: "
                        ++ tournamentId
                        ++ ", unitsSold: "
                        ++ toString dollars
                        ++ ", markup: "
                        ++ toString markup
                        ++ ", playerName: \""
                        ++ userName
                        ++ "\")"
                        ++ "{ id, name, city, tournaments {id, feeInCents, name, result, stakingContracts { percentsSold, staker { name }, rate }} }"
                        ++ "}"
                    )
              )
            ]
        )


createResult : Model -> Maybe AuthenticatedUser -> TournamentId -> PlayerId -> Cmd Msg
createResult model user tournamentId playerId =
    case user of
        Just user ->
            Http.send UpdateTournamentSeriesesShow <|
                authenticatedRequest
                    "/api"
                    user.token
                    (newResultRequestBody model.formData.result.prize tournamentId playerId)
                    (graphQlDecoder "createResult" (Json.Decode.list tournamentSeriesDecoder))

        Nothing ->
            Cmd.none


newResultRequestBody : Int -> TournamentId -> PlayerId -> Body
newResultRequestBody prize tournamentId playerId =
    Http.jsonBody
        (Json.Encode.object
            [ ( "query"
              , Json.Encode.string
                    ("mutation { createResult(prize: "
                        ++ toString (prize)
                        ++ ", tournamentId: \""
                        ++ tournamentId
                        ++ "\""
                        ++ ", playerId: \""
                        ++ playerId
                        ++ "\")"
                        ++ "{ id, name, city, tournaments {id, feeInCents, name, result, stakingContracts { percentsSold, staker { name }, rate }} }"
                        ++ "}"
                    )
              )
            ]
        )


createNewStakingContract : Model -> Maybe AuthenticatedUser -> TournamentId -> Cmd Msg
createNewStakingContract model user tournamentId =
    case user of
        Just user ->
            Http.send UpdateTournamentSeriesesShow <|
                authenticatedRequest
                    "/api"
                    user.token
                    (newStakeContractRequestBody
                        model.formData.stakingContract.stakerId
                        model.formData.stakingContract.percentsSold
                        model.userId
                        model.formData.stakingContract.rate
                        tournamentId
                    )
                    (graphQlDecoder "createStakingContract" (Json.Decode.list tournamentSeriesDecoder))

        Nothing ->
            Cmd.none


newStakeContractRequestBody : String -> Float -> String -> Float -> String -> Body
newStakeContractRequestBody stakerId percentsSold userId rate tournamentId =
    Http.jsonBody
        (Json.Encode.object
            [ ( "query"
              , Json.Encode.string
                    ("mutation { createStakingContract(percentsSold: "
                        ++ toString percentsSold
                        ++ ", rate: "
                        ++ toString rate
                        ++ ", stakerId: "
                        ++ stakerId
                        ++ ", tournamentId: "
                        ++ tournamentId
                        ++ ", playerId: "
                        ++ userId
                        ++ ")"
                        ++ "{ id, name, city, tournaments {id, feeInCents, name, result, stakingContracts { percentsSold, staker { name }, rate }} }"
                        ++ "}"
                    )
              )
            ]
        )


authenticatedRequest : String -> String -> Body -> Json.Decode.Decoder a -> Request a
authenticatedRequest url token body decoder =
    Http.request
        { method = "POST"
        , headers = [ Http.header "Authorization" ("Token " ++ token) ]
        , url = url
        , body = body
        , expect = Http.expectJson decoder
        , timeout = Nothing
        , withCredentials = False
        }


graphQlDecoder : String -> Json.Decode.Decoder a -> Json.Decode.Decoder a
graphQlDecoder fieldName decoder =
    field "data" <|
        field fieldName <|
            decoder


tournamentSeriesDecoder : Json.Decode.Decoder TournamentSeries
tournamentSeriesDecoder =
    map4 TournamentSeries
        (field "city" Json.Decode.string)
        (field "id" Json.Decode.string)
        (field "name" Json.Decode.string)
        (field "tournaments" (Json.Decode.list tournamentDecoder))


tournamentDecoder : Json.Decode.Decoder Tournament
tournamentDecoder =
    map5 Tournament
        (field "id" Json.Decode.string)
        (field "feeInCents" Json.Decode.int)
        (field "name" Json.Decode.string)
        (field "result" (maybe Json.Decode.int))
        (field "stakingContracts" (Json.Decode.list stakingContractDecoder))


stakingContractDecoder : Json.Decode.Decoder StakingContract
stakingContractDecoder =
    map3 StakingContract
        (field "rate" Json.Decode.float)
        (field "staker" stakerDecoder)
        (field "percentsSold" Json.Decode.float)


stakerDecoder : Json.Decode.Decoder Staker
stakerDecoder =
    Json.Decode.map Staker
        (field "name" Json.Decode.string)


view : Model -> Html Msg
view model =
    div []
        [ newSeries
        , allSerieses model
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
                [ text "fee"
                , input
                    [ name "fee"
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
        [ tournamentHeader tournament
        , createActionSale tournament.id
        , br [] []
        ]


tournamentHeader : Tournament -> Html Msg
tournamentHeader tournament =
    h4 [] [ text (tournament.name ++ " (" ++ formatMoney tournament.fee_in_cents ++ ")") ]


createActionSale : String -> Html Msg
createActionSale tournamentId =
    div []
        [ text "sell action"
        , Html.form
            [ onSubmit (CreateActionSale tournamentId) ]
            [ label []
                [ text "Dollars"
                , input
                    [ name "dollars"
                    , onInput <| SetActionDollars
                    ]
                    []
                ]
            , label []
                [ text "Markup"
                , input
                    [ name "markup"
                    , onInput <| SetActionMarkup
                    ]
                    []
                ]
            , button [] [ text "submit" ]
            ]
        ]


viewStakingContract : Tournament -> StakingContract -> Html Msg
viewStakingContract tournament stakingContract =
    li []
        [ text
            (stakingContract.staker.name
                ++ " | rate: "
                ++ toString stakingContract.rate
                ++ " | percents_sold: "
                ++ toString stakingContract.percentsSold
                ++ " | cost: "
                ++ formatContractCost stakingContract tournament.fee_in_cents
                ++ formatContractWinnings tournament stakingContract
            )
        ]


newStakingContract : Tournament -> Html Msg
newStakingContract tournament =
    case tournament.result of
        Nothing ->
            div []
                [ text "add a new staker for this tournament below"
                , newStakerForm tournament
                ]

        Just _ ->
            div [] []


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
                [ text "percents sold"
                , input
                    [ name "percents-sold"
                    , onInput <| SetFormData (SettStakingContract PercentsSold)
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


viewTournamentResult : Tournament -> Html Msg
viewTournamentResult tournament =
    case tournament.result of
        Just prize ->
            h4 [] [ text ("you won " ++ formatMoney prize) ]

        Nothing ->
            div []
                [ Html.form
                    [ onSubmit (CreateNewResult tournament.id "1") ]
                    [ label []
                        [ text "prize"
                        , input
                            [ name "prize"
                            , onInput <| SetFormData (SettResult Prize)
                            ]
                            []
                        ]
                    , button [] [ text "submit" ]
                    ]
                ]


formatContractCost : StakingContract -> Int -> String
formatContractCost stakingContract tournamentFee =
    (toFloat tournamentFee / 100)
        * stakingContract.percentsSold
        * stakingContract.rate
        |> ceiling
        |> formatMoney


formatContractWinnings : Tournament -> StakingContract -> String
formatContractWinnings tournament stakingContract =
    case tournament.result of
        Just prize ->
            " | winnings: " ++ formatMoney (floor ((toFloat prize / 100) * stakingContract.percentsSold))

        Nothing ->
            ""


formatMoney : Int -> String
formatMoney totalPence =
    let
        beforeTheDot =
            separateThousands ((abs totalPence) // 100)

        afterTheDot =
            lastNDigits 2 (abs totalPence)

        sign =
            if totalPence >= 0 then
                ""
            else
                "-"
    in
        sign ++ "$ " ++ beforeTheDot ++ "." ++ afterTheDot


separateThousands : Int -> String
separateThousands total =
    doSeparateThousands total ""


doSeparateThousands : Int -> String -> String
doSeparateThousands digitsLeft accumulator =
    if digitsLeft > 1000 then
        let
            newDigitsLeft =
                (digitsLeft // 1000)

            newAccumulator =
                ("," ++ (lastNDigits 3 digitsLeft) ++ accumulator)
        in
            doSeparateThousands newDigitsLeft newAccumulator
    else
        (toString digitsLeft) ++ accumulator


lastNDigits : Int -> Int -> String
lastNDigits n fullNumber =
    let
        nDigits =
            rem fullNumber (10 ^ n)
    in
        if nDigits == 0 then
            String.repeat n "0"
        else
            toString (nDigits)


createTournament : Model -> Maybe AuthenticatedUser -> SeriesId -> Cmd Msg
createTournament model user seriesId =
    case user of
        Just user ->
            Http.send UpdateTournamentSeriesesShow <|
                authenticatedRequest
                    "/api"
                    user.token
                    (newTournamentRequestBody model.formData.tournament.name model.formData.tournament.feeInCents seriesId)
                    (graphQlDecoder "createTournament" (Json.Decode.list tournamentSeriesDecoder))

        Nothing ->
            Cmd.none


newTournamentRequestBody : String -> Int -> SeriesId -> Body
newTournamentRequestBody name feeInCents seriesId =
    Http.jsonBody
        (Json.Encode.object
            [ ( "query"
              , Json.Encode.string
                    ("mutation { createTournament(name: \""
                        ++ name
                        ++ "\", feeInCents: "
                        ++ toString feeInCents
                        ++ ", tournamentSeriesId: \""
                        ++ seriesId
                        ++ "\")"
                        ++ "{ id, name, city, tournaments {id, feeInCents, name, result, stakingContracts { percentsSold, staker { name }, rate }} }"
                        ++ "}"
                    )
              )
            ]
        )


createTournamentSeries : Model -> Maybe AuthenticatedUser -> Cmd Msg
createTournamentSeries model user =
    case user of
        Just user ->
            Http.send UpdateTournamentSeriesesShow <|
                authenticatedRequest
                    "/api"
                    user.token
                    (newTournamentSeriesRequestBody model.formData.tournamentSeries.city model.formData.tournamentSeries.name)
                    (graphQlDecoder "createTournamentSeries" (Json.Decode.list tournamentSeriesDecoder))

        Nothing ->
            Cmd.none


newTournamentSeriesRequestBody : String -> String -> Body
newTournamentSeriesRequestBody city name =
    Http.jsonBody
        (Json.Encode.object
            [ ( "query"
              , Json.Encode.string
                    ("mutation { createTournamentSeries(city: \""
                        ++ city
                        ++ "\", name: \""
                        ++ name
                        ++ "\")"
                        ++ "{ id, name, city, tournaments {id, feeInCents, name, result, stakingContracts { percentsSold, staker { name }, rate }} }"
                        ++ "}"
                    )
              )
            ]
        )


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


updateTournamentSeriesesShown : Model -> Result Http.Error (List TournamentSeries) -> ( Model, Cmd Msg )
updateTournamentSeriesesShown model result =
    case result of
        Ok serieses ->
            ( { model | tournamentSerieses = serieses }, Cmd.none )

        Err (BadPayload message response) ->
            ( { model | stuff = message }, Cmd.none )

        Err _ ->
            ( { model | stuff = "error fetching tournaments" }, Cmd.none )
