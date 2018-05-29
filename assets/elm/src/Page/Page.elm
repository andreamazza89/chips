module Page.Page exposing (Page(..))

import Page.Authentication as Auth


type Page
    = Authentication Auth.Model
    | OldPage
