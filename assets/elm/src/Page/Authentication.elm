module Page.Authentication exposing (ExternalMsg(..), Model, Msg(..), createUserRequest, initialCmd, initialModel, update, view)

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (onInput, onSubmit)
import Http exposing (..)
import Json.Encode exposing (encode, object)
import Json.Decode exposing (..)
import User exposing (AuthenticatedUser)


type alias Model =
    { email : String
    , error : Maybe String
    , password : String
    , userName : String
    }


type Msg
    = CreateUser
    | LoginUser
    | SetEmail String
    | SetPassword String
    | SetUserName String
    | UserCreated (Result Http.Error AuthenticatedUser)
    | UserLoggedIn (Result Http.Error AuthenticatedUser)


type ExternalMsg
    = NoOp
    | SetUser AuthenticatedUser


initialModel : Model
initialModel =
    Model "" Nothing "" ""


update : ( Model, Msg ) -> ( ( Model, Cmd Msg ), ExternalMsg )
update ( model, msg ) =
    case msg of
        CreateUser ->
            ( ( model, createUserRequest model ), NoOp )

        LoginUser ->
            ( ( model, loginUserRequest model ), NoOp )

        SetEmail input ->
            ( ( { model | email = input, error = Nothing }, Cmd.none ), NoOp )

        SetUserName input ->
            ( ( { model | userName = input, error = Nothing }, Cmd.none ), NoOp )

        SetPassword input ->
            ( ( { model | password = input, error = Nothing }, Cmd.none ), NoOp )

        UserCreated (Ok authenticatedUser) ->
            ( ( initialModel, Cmd.none ), SetUser authenticatedUser )

        UserCreated (Err (BadPayload message response)) ->
            ( ( { model | error = Just message }, Cmd.none ), NoOp )

        UserCreated (Err _) ->
            ( ( { model | error = Just "something went wrong" }, Cmd.none ), NoOp )

        UserLoggedIn (Ok authenticatedUser) ->
            ( ( initialModel, Cmd.none ), SetUser authenticatedUser )

        UserLoggedIn (Err (BadPayload message response)) ->
            ( ( { model | error = Just message }, Cmd.none ), NoOp )

        UserLoggedIn (Err _) ->
            ( ( { model | error = Just "something went wrong" }, Cmd.none ), NoOp )


view : Model -> Html Msg
view model =
    div []
        [ h3 [] [ text "Sign up" ]
        , viewError model.error
        , Html.form
            [ onSubmit CreateUser ]
            [ label []
                [ text "Username"
                , input
                    [ name "user-name"
                    , onInput <| SetUserName
                    ]
                    []
                ]
            , label []
                [ text "Email"
                , input
                    [ name "email"
                    , onInput <| SetEmail
                    ]
                    []
                ]
            , label []
                [ text "Password"
                , input
                    [ name "password"
                    , onInput <| SetPassword
                    ]
                    []
                ]
            , button [] [ text "submit" ]
            ]
        , h3 [] [ text "Login" ]
        , Html.form
            [ onSubmit LoginUser ]
            [ label []
                [ text "Username"
                , input
                    [ name "user-name"
                    , onInput <| SetUserName
                    ]
                    []
                ]
            , label []
                [ text "Password"
                , input
                    [ name "password"
                    , onInput <| SetPassword
                    ]
                    []
                ]
            , button [] [ text "submit" ]
            ]
        ]


viewError : Maybe String -> Html Msg
viewError error =
    case error of
        Just errorMessage ->
            p [] [ text errorMessage ]

        Nothing ->
            div [] []


createUserRequest : Model -> Cmd Msg
createUserRequest model =
    Http.send UserCreated <|
        Http.post
            "/api/users"
            (createUserRequestBody model)
            userDecoder


loginUserRequest : Model -> Cmd Msg
loginUserRequest { userName, password } =
    Http.send UserLoggedIn <|
        Http.get
            ("/api/users/"
                ++ userName
                ++ "?password="
                ++ password
            )
            userDecoder


userDecoder : Json.Decode.Decoder AuthenticatedUser
userDecoder =
    map3 AuthenticatedUser
        (field "email" string)
        (field "token" string)
        (field "user_name" string)


createUserRequestBody : Model -> Body
createUserRequestBody { email, password, userName } =
    Http.jsonBody
        (Json.Encode.object
            [ ( "email", Json.Encode.string email )
            , ( "password", Json.Encode.string password )
            , ( "user_name", Json.Encode.string userName )
            ]
        )


loginUserRequestBody : Model -> Body
loginUserRequestBody { password, userName } =
    Http.jsonBody
        (Json.Encode.object
            [ ( "password", Json.Encode.string password )
            , ( "user_name", Json.Encode.string userName )
            ]
        )


initialCmd : Cmd Msg
initialCmd =
    Cmd.none
