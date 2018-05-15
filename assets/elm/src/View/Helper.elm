module View.Helper exposing (formatContractCost, formatContractWinnings, formatMoney)

import Data exposing (..)


formatContractCost : StakingContract -> Int -> String
formatContractCost stakingContract tournamentFee =
    (toFloat tournamentFee / 100)
        * stakingContract.percentsSold
        * stakingContract.rate
        |> ceiling
        |> formatMoney


formatContractWinnings : Tournament -> StakingContract -> String
formatContractWinnings tournament stakingContract =
    case tournament.result of
        Just prize ->
            " | winnings: " ++ formatMoney (floor ((toFloat prize / 100) * stakingContract.percentsSold))

        Nothing ->
            ""


formatMoney : Int -> String
formatMoney totalPence =
    let
        afterTheDot =
            blah (abs totalPence)

        beforeTheDot =
            separateThousands ((abs totalPence) // 100)

        isPositive =
            totalPence >= 0

        formattedAbsoluteMoney =
            "$ " ++ beforeTheDot ++ "." ++ afterTheDot
    in
        if isPositive then
            formattedAbsoluteMoney
        else
            "-" ++ formattedAbsoluteMoney


blah : Int -> String
blah total =
    let
        rawAfterTheDot =
            rem total 100
    in
        if rawAfterTheDot == 0 then
            "00"
        else
            toString rawAfterTheDot


separateThousands : Int -> String
separateThousands total =
    doSeparateThousands total ""


doSeparateThousands : Int -> String -> String
doSeparateThousands digitsLeft accumulator =
    if digitsLeft > 1000 then
        doSeparateThousands (digitsLeft // 1000) ("," ++ (toString (rem digitsLeft 1000)) ++ accumulator)
    else
        (toString digitsLeft) ++ accumulator
