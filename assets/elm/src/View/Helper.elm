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
        beforeTheDot =
            separateThousands ((abs totalPence) // 100)

        afterTheDot =
            lastNDigits 2 (abs totalPence)

        sign =
            if totalPence >= 0 then
                ""
            else
                "-"
    in
        sign ++ "$ " ++ beforeTheDot ++ "." ++ afterTheDot


separateThousands : Int -> String
separateThousands total =
    doSeparateThousands total ""


doSeparateThousands : Int -> String -> String
doSeparateThousands digitsLeft accumulator =
    if digitsLeft > 1000 then
        let
            newDigitsLeft =
                (digitsLeft // 1000)

            newAccumulator =
                ("," ++ (lastNDigits 3 digitsLeft) ++ accumulator)
        in
            doSeparateThousands newDigitsLeft newAccumulator
    else
        (toString digitsLeft) ++ accumulator


lastNDigits : Int -> Int -> String
lastNDigits n fullNumber =
    let
        nDigits =
            rem fullNumber (10 ^ n)
    in
        if nDigits == 0 then
            String.repeat n "0"
        else
            toString (nDigits)
