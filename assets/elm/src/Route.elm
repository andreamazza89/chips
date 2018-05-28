module Route exposing (spitMsgFromLocation)

import Data exposing (Msg(SetRoute), Route(..))
import Navigation exposing (Location, program)


spitMsgFromLocation : Location -> Msg
spitMsgFromLocation location =
    if location.hash == "#/ciao" then
        SetRoute GoToOldPage
    else
        SetRoute GoToNewPage
