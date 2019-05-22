module AMG.Encoder exposing (encoder)

import AMG.Bitwise exposing (..)
import Bytes exposing (..)
import Bytes.Encode exposing (..)
import Data exposing (..)
import EverySet


encoder : Game -> Encoder
encoder game =
    sequence
        [ head game
        , stages game
        , end
        ]


head : Game -> Encoder
head game =
    sequence
        [ string "HEAD"
        , dword 0
        ]


stages : Game -> Encoder
stages game =
    sequence <|
        List.map stage game.stages


stage : Stage -> Encoder
stage s =
    let
        level =
            case s.level of
                Easy ->
                    "EASY"

                Normal ->
                    "NORMAL"

                Hard ->
                    "HARD"

                SuperHard ->
                    "SUPR"

                AltEasy ->
                    "DA_E"

                AltNormal ->
                    "DA_N"

                AltHard ->
                    "DA_H"

                AltSuperHard ->
                    "DA_S"

        player =
            case s.player of
                P1 ->
                    0

                P2 ->
                    1

        body =
            encode <|
                sequence
                    [ dword player
                    , dword s.maxScore
                    , dword (List.length s.inputs)
                    , sequence <|
                        List.map input s.inputs
                    ]

        bodySize =
            ceiling (toFloat (width body) / 4) * 4
    in
    sequence
        [ string level
        , dword bodySize
        , bytes body
        ]


input : Input -> Encoder
input i =
    sequence
        [ dword (floor (i.pos * 60))
        , dword (cmd i)
        ]


cmd : Input -> Int
cmd i =
    1
        |> set 4 (EverySet.member LeftUp i.hits)
        |> set 5 (EverySet.member LeftMiddle i.hits)
        |> set 6 (EverySet.member LeftDown i.hits)
        |> set 7 (EverySet.member RightUp i.hits)
        |> set 8 (EverySet.member RightMiddle i.hits)
        |> set 9 (EverySet.member RightDown i.hits)


end : Encoder
end =
    string "END_"


dword : Int -> Encoder
dword =
    unsignedInt32 LE
