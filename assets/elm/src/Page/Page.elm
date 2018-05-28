module Page.Page exposing (Page(..))

import Page.Foo as Foo


type Page
    = Foo Foo.Model
    | OldPage
