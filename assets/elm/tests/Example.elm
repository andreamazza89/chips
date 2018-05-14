module Example exposing (..)

import Expect exposing (Expectation)
import Test exposing (..)


suite : Test
suite =
    test "A moot point" <|
        \_ -> Expect.equal 42 42
