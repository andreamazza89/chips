module ViewHelperTest exposing (..)

import Expect exposing (Expectation)
import Test exposing (..)
import View.Helper exposing (formatMoney)


suite : Test
suite =
    describe "Format money"
        [ test "easy" <|
            \_ ->
                4242
                    |> formatMoney
                    |> Expect.equal "$ 42.42"
        , test "medium" <|
            \_ ->
                90512345600
                    |> formatMoney
                    |> Expect.equal "$ 905,123,456.00"
        , test "hard" <|
            \_ ->
                9876540
                    |> formatMoney
                    |> Expect.equal "$ 98,765.40"
        , test "negative" <|
            \_ ->
                -2776511
                    |> formatMoney
                    |> Expect.equal "-$ 27,765.11"
        ]
