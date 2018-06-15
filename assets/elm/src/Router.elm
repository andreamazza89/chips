module Router exposing (Route(..), resolve, locationToRoute)

import Page.Authentication as Auth
import Page.MarketPlace as Market
import Page.Page as Page exposing (Page(..))
import Navigation exposing (Location, program)


type Route
    = GoToOldPage
    | GoToNewPage


resolve : Route -> Page
resolve route =
    case route of
        GoToOldPage ->
            MarketPlace Market.initialModel

        GoToNewPage ->
            Authentication Auth.initialModel


locationToRoute : Location -> Route
locationToRoute location =
    if location.hash == "#/marketplace" then
        GoToOldPage
    else
        GoToNewPage
