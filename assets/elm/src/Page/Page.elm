module Page.Page exposing (Page(..))

import Page.Authentication as Auth
import Page.MarketPlace as Market


type Page
    = Authentication Auth.Model
    | MarketPlace Market.Model
    | OldPage
