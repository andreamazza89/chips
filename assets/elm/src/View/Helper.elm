module View.Helper exposing (formatContractCost, formatContractWinnings)

import Data exposing (..)


formatContractCost : StakingContract -> Int -> String
formatContractCost stakingContract tournamentFee =
    (toFloat tournamentFee / 100)
        * stakingContract.percentsSold
        * stakingContract.rate
        |> ceiling
        |> toString


formatContractWinnings : Tournament -> StakingContract -> String
formatContractWinnings tournament stakingContract =
    case tournament.result of
        Just prize ->
            " | winnings: " ++ toString ((toFloat prize / 100) * stakingContract.percentsSold)

        Nothing ->
            ""
