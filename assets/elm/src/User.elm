module User exposing (AuthenticatedUser)


type alias AuthenticatedUser =
    { email : String
    , token : String
    , userName : String
    }
