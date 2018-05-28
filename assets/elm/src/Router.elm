module Router exposing (Route(..), resolve, locationToRoute)

import Page.Foo as Foo
import Page.Page as Page exposing (Page(..))
import Navigation exposing (Location, program)


type Route
    = GoToOldPage
    | GoToNewPage


resolve : Route -> Page
resolve route =
    case route of
        GoToOldPage ->
            OldPage

        GoToNewPage ->
            Foo Foo.initialModel


locationToRoute : Location -> Route
locationToRoute location =
    if location.hash == "#/ciao" then
        GoToOldPage
    else
        GoToNewPage
