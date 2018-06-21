module Page.MarketPlace exposing (Model, Msg, formatMoney, initialCmd, initialModel, view, update)

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Http
import Http exposing (..)
import Json.Decode exposing (..)
import Json.Encode exposing (..)
import User exposing (AuthenticatedUser)


type alias Model =
    { actionUnitsToSell : Int
    , actionMarkup : Float
    , actionResult : Int
    , formData : FormData
    , stuff : String
    , actionUnitsToBuy : Int
    , tournamentSerieses : List TournamentSeries
    }


type alias FormData =
    { result : ResultData
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


type alias TournamentSeriesData =
    { city : String
    , name : String
    }


type alias SaleId =
    String


type Msg
    = CreateActionSale String
    | CreateActionSaleResult String
    | CreateNewTournament SeriesId
    | CreateNewTournamentSeries
    | CreateNewUser
    | PurchaseAction SaleId
    | SetFormData Specifics String
    | SetActionDollars String
    | SetActionMarkup String
    | SetActionResult String
    | SetActionUnitsToBuy String
    | UpdateTournamentSeriesesShow (Result Http.Error (List TournamentSeries))
    | UpdateUsersShown (Result Http.Error (List User))


type ExternalMsg
    = NoOp


type Specifics
    = SettResult ResultFormData
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


type alias ActionSale =
    { actionPurchases : List ActionPurchase
    , id : String
    , markup : Float
    , result : Maybe Int
    , units_on_sale : Int
    , user_name : String
    }


type alias ActionPurchase =
    { unitsBought : Int
    , userName : String
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
    , actionSales : List ActionSale
    }


type alias PlayerId =
    String


type alias TournamentId =
    String


initialModel : Model
initialModel =
    { actionUnitsToSell = 0
    , actionMarkup = 0
    , actionResult = 0
    , actionUnitsToBuy = 0
    , formData = initialFormData
    , stuff = "errors go here"
    , tournamentSerieses = []
    }


initialCmd : AuthenticatedUser -> Cmd Msg
initialCmd user =
    fetchSerieses user.token


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
                        ++ " tournaments { feeInCents, name, id, actionSales { id, markup, result, units_on_sale, user_name, actionPurchases { userName, unitsBought } } } } }"
                    )
              )
            ]
        )


initialFormData : FormData
initialFormData =
    { result = { prize = 0 }
    , tournament = { name = "", feeInCents = 0 }
    , tournamentSeries = { city = "", name = "" }
    , user = { name = "", email = "" }
    }


update : AuthenticatedUser -> ( Model, Msg ) -> ( ( Model, Cmd Msg ), ExternalMsg )
update user ( model, msg ) =
    case msg of
        CreateActionSale tournamentId ->
            ( ( model, createActionSaleRequest model user tournamentId ), NoOp )

        CreateActionSaleResult actionSaleId ->
            ( ( model, createActionSaleResult model.actionResult user actionSaleId ), NoOp )

        CreateNewTournament seriesId ->
            ( ( model, createTournament model user seriesId ), NoOp )

        CreateNewTournamentSeries ->
            ( ( model, createTournamentSeries model user ), NoOp )

        PurchaseAction actionSaleId ->
            ( ( model, createActionPurchase actionSaleId model user ), NoOp )

        SetActionDollars input ->
            case String.toInt input of
                Ok dollars ->
                    ( ( { model | actionUnitsToSell = dollars }, Cmd.none ), NoOp )

                Err msg ->
                    ( ( { model | stuff = msg }, Cmd.none ), NoOp )

        SetActionMarkup input ->
            case String.toFloat input of
                Ok markup ->
                    ( ( { model | actionMarkup = markup }, Cmd.none ), NoOp )

                Err msg ->
                    ( ( { model | stuff = msg }, Cmd.none ), NoOp )

        SetActionResult input ->
            case String.toInt input of
                Ok prize ->
                    ( ( { model | actionResult = prize }, Cmd.none ), NoOp )

                Err msg ->
                    ( ( { model | stuff = msg }, Cmd.none ), NoOp )

        SetActionUnitsToBuy input ->
            case String.toInt input of
                Ok units ->
                    ( ( { model | actionUnitsToBuy = units }, Cmd.none ), NoOp )

                Err msg ->
                    ( ( { model | stuff = msg }, Cmd.none ), NoOp )

        SetFormData formSpecifics userInput ->
            ( handleFormInput model formSpecifics userInput, NoOp )

        UpdateTournamentSeriesesShow result ->
            ( updateTournamentSeriesesShown model result, NoOp )

        -- remove this catchall once cleaned up the old stuff
        _ ->
            ( ( model, Cmd.none ), NoOp )


createActionPurchase : SaleId -> Model -> AuthenticatedUser -> Cmd Msg
createActionPurchase actionSaleId model user =
    Http.send UpdateTournamentSeriesesShow <|
        authenticatedRequest
            "/api"
            user.token
            (createActionPurchaseRequestBody actionSaleId model.actionUnitsToBuy)
            (graphQlDecoder "createActionPurchase" (Json.Decode.list tournamentSeriesDecoder))


createActionPurchaseRequestBody : SaleId -> Int -> Body
createActionPurchaseRequestBody actionSaleId unitsToBuy =
    Http.jsonBody
        (Json.Encode.object
            [ ( "query"
              , Json.Encode.string
                    ("mutation { createActionPurchase(actionSaleId: \""
                        ++ actionSaleId
                        ++ "\", unitsBought: "
                        ++ toString unitsToBuy
                        ++ ")"
                        ++ "{ id, name, city, tournaments { feeInCents, name, id, actionSales { id, markup, result, units_on_sale, user_name, actionPurchases { userName, unitsBought } } } }"
                        ++ "}"
                    )
              )
            ]
        )


createActionSaleRequest : Model -> AuthenticatedUser -> String -> Cmd Msg
createActionSaleRequest model user tournamentId =
    Http.send UpdateTournamentSeriesesShow <|
        authenticatedRequest
            "/api"
            user.token
            (createActionSaleRequestBody tournamentId model.actionUnitsToSell model.actionMarkup)
            (graphQlDecoder "createActionSale" (Json.Decode.list tournamentSeriesDecoder))


createActionSaleRequestBody : String -> Int -> Float -> Body
createActionSaleRequestBody tournamentId dollars markup =
    Http.jsonBody
        (Json.Encode.object
            [ ( "query"
              , Json.Encode.string
                    ("mutation { createActionSale(tournamentId: \""
                        ++ tournamentId
                        ++ "\", unitsOnSale: "
                        ++ toString dollars
                        ++ ", markup: "
                        ++ toString markup
                        ++ ")"
                        ++ "{ id, name, city, tournaments { feeInCents, name, id, actionSales { id, markup, result, units_on_sale, user_name, actionPurchases { userName, unitsBought } } } }"
                        ++ "}"
                    )
              )
            ]
        )


createActionSaleResult : Int -> AuthenticatedUser -> String -> Cmd Msg
createActionSaleResult actionResult user actionSaleId =
    Http.send UpdateTournamentSeriesesShow <|
        authenticatedRequest
            "/api"
            user.token
            (actionSaleResultRequestBody actionResult actionSaleId)
            (graphQlDecoder "createActionSaleResult" (Json.Decode.list tournamentSeriesDecoder))


actionSaleResultRequestBody : Int -> String -> Body
actionSaleResultRequestBody actionSaleResult actionSaleId =
    Http.jsonBody
        (Json.Encode.object
            [ ( "query"
              , Json.Encode.string
                    ("mutation { createActionSaleResult(actionSaleResult: "
                        ++ toString (actionSaleResult)
                        ++ ", actionSaleId: \""
                        ++ actionSaleId
                        ++ "\")"
                        ++ "{ id, name, city, tournaments { feeInCents, name, id, actionSales { id, markup, result, units_on_sale, user_name, actionPurchases { userName, unitsBought } } } }"
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
    map4 Tournament
        (field "id" Json.Decode.string)
        (field "feeInCents" Json.Decode.int)
        (field "name" Json.Decode.string)
        (field "actionSales" (Json.Decode.list actionSaleDecoder))


actionSaleDecoder : Json.Decode.Decoder ActionSale
actionSaleDecoder =
    map6 ActionSale
        (field "actionPurchases" (Json.Decode.list actionPurchaseDecoder))
        (field "id" Json.Decode.string)
        (field "markup" Json.Decode.float)
        (field "result" (nullable Json.Decode.int))
        (field "units_on_sale" Json.Decode.int)
        (field "user_name" Json.Decode.string)


actionPurchaseDecoder : Json.Decode.Decoder ActionPurchase
actionPurchaseDecoder =
    map2 ActionPurchase
        (field "unitsBought" Json.Decode.int)
        (field "userName" Json.Decode.string)


stakerDecoder : Json.Decode.Decoder Staker
stakerDecoder =
    Json.Decode.map Staker
        (field "name" Json.Decode.string)


view : Model -> Html Msg
view model =
    div []
        [ text model.stuff
        , newSeries
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
        , viewActionSales tournament.actionSales
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
                [ text "How much? (in cents)"
                , input
                    [ name "cents"
                    , onInput <| SetActionDollars
                    ]
                    []
                ]
            , label []
                [ text "At what markup?"
                , input
                    [ name "markup"
                    , onInput <| SetActionMarkup
                    ]
                    []
                ]
            , button [] [ text "sell action" ]
            ]
        ]


viewActionSales : List ActionSale -> Html Msg
viewActionSales sales =
    div [] (List.map viewActionSale sales)


viewActionSale : ActionSale -> Html Msg
viewActionSale sale =
    div []
        [ div [] [ text "--------------------" ]
        , text (sale.user_name ++ " is selling " ++ (toString sale.units_on_sale) ++ " at " ++ (toString sale.markup) ++ "% markup")
        , actionForms sale
        , viewPurchases sale.actionPurchases
        , div [] [ text "--------------------" ]
        ]


actionForms : ActionSale -> Html Msg
actionForms sale =
    case sale.result of
        Nothing ->
            div [] [ buyActionForm sale.id, publishResultForm sale.id ]

        Just result ->
            div [] [ text ("sale is over; the prize was: " ++ (formatMoney result)) ]


buyActionForm : SaleId -> Html Msg
buyActionForm saleId =
    Html.form
        [ onSubmit (PurchaseAction saleId) ]
        [ label []
            [ text "buy action (cents): "
            , input
                [ name "action"
                , onInput <| SetActionUnitsToBuy
                ]
                []
            ]
        ]


publishResultForm : SaleId -> Html Msg
publishResultForm saleId =
    Html.form
        [ onSubmit (CreateActionSaleResult saleId) ]
        [ label []
            [ text "publish result (cents): "
            , input
                [ name "publish-result"
                , onInput <| SetActionResult
                ]
                []
            ]
        ]


viewPurchases : List ActionPurchase -> Html Msg
viewPurchases purchases =
    div [] (List.map viewPurchase purchases)


viewPurchase : ActionPurchase -> Html Msg
viewPurchase purchase =
    div []
        [ text purchase.userName
        , text " bought "
        , text (formatMoney purchase.unitsBought)
        ]


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


createTournament : Model -> AuthenticatedUser -> SeriesId -> Cmd Msg
createTournament model user seriesId =
    Http.send UpdateTournamentSeriesesShow <|
        authenticatedRequest
            "/api"
            user.token
            (newTournamentRequestBody model.formData.tournament.name model.formData.tournament.feeInCents seriesId)
            (graphQlDecoder "createTournament" (Json.Decode.list tournamentSeriesDecoder))


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
                        ++ "{ id, name, city, tournaments { feeInCents, name, id, actionSales { id, markup, result, units_on_sale, user_name, actionPurchases { userName, unitsBought } } } }"
                        ++ "}"
                    )
              )
            ]
        )


createTournamentSeries : Model -> AuthenticatedUser -> Cmd Msg
createTournamentSeries model user =
    Http.send UpdateTournamentSeriesesShow <|
        authenticatedRequest
            "/api"
            user.token
            (newTournamentSeriesRequestBody model.formData.tournamentSeries.city model.formData.tournamentSeries.name)
            (graphQlDecoder "createTournamentSeries" (Json.Decode.list tournamentSeriesDecoder))


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
                        ++ "{ id, name, city, tournaments { feeInCents, name, id, actionSales { id, markup, result, units_on_sale, user_name, actionPurchases { userName, unitsBought } } } }"
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


updateTournamentSeriesesShown : Model -> Result Http.Error (List TournamentSeries) -> ( Model, Cmd Msg )
updateTournamentSeriesesShown model result =
    case result of
        Ok serieses ->
            ( { model | tournamentSerieses = serieses }, Cmd.none )

        Err (BadPayload message response) ->
            ( { model | stuff = message }, Cmd.none )

        Err _ ->
            ( { model | stuff = "error fetching tournaments" }, Cmd.none )
