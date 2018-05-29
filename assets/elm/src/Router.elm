module Router exposing (Route(..), resolve, locationToRoute)

import Page.Authentication as Auth
import Page.Page as Page exposing (Page(..))
import Navigation exposing (Location, program)


type Route
    = GoToOldPage
    | GoToNewPage


resolve : Route -> Bool -> Page
resolve route userIsAuthenticated =
    if userIsAuthenticated then
        case route of
            GoToOldPage ->
                OldPage

            GoToNewPage ->
                Authentication Auth.initialModel
    else
        Authentication Auth.initialModel


locationToRoute : Location -> Route
locationToRoute location =
    if location.hash == "#/ciao" then
        GoToOldPage
    else
        GoToNewPage
