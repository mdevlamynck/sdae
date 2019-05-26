module AMGTest exposing (suite)

import AMG
import AMG.Decoder
import AMG.Encoder exposing (emptyGame)
import Bytes exposing (Bytes)
import Bytes.Encode as Bytes
import Bytes.Parser as Bytes
import Data exposing (..)
import EverySet
import Expect exposing (Expectation)
import Fuzz exposing (..)
import Random
import Test exposing (..)


game : Fuzzer Game
game =
    map (\stages -> { emptyGame | stages = stages })
        (list stage)


stage : Fuzzer Stage
stage =
    map4 Stage
        (oneOf
            [ constant Easy
            , constant Normal
            , constant Hard
            , constant SuperHard
            ]
        )
        (oneOf
            [ constant P1
            , constant P2
            ]
        )
        (intRange 0 Random.maxInt)
        (list input)


input : Fuzzer Input
input =
    let
        hits =
            list
                (oneOf
                    [ constant LeftUp
                    , constant LeftMiddle
                    , constant LeftDown
                    , constant RightUp
                    , constant RightMiddle
                    , constant RightDown
                    ]
                )
                |> map (List.sortBy hitValue)
                |> map EverySet.fromList
    in
    oneOf
        [ map5 Input
            hits
            (intRange 0 Random.maxInt)
            (constant 3)
            (constant 0)
            (constant Regular)
        , map5 Input
            hits
            (intRange 0 Random.maxInt)
            (constant 3)
            (constant 60)
            (constant Pose)
        , map5 Input
            hits
            (intRange 0 Random.maxInt)
            (constant 3)
            (intRange 60 120)
            (constant Long)
        ]


hitValue hit =
    case hit of
        LeftUp ->
            0

        LeftMiddle ->
            1

        LeftDown ->
            2

        RightUp ->
            3

        RightMiddle ->
            4

        RightDown ->
            5


suite : Test
suite =
    describe "AMG"
        [ fuzz game "Encoded then decoded game is unchanged" <|
            \g ->
                g
                    |> (AMG.encode >> Bytes.run AMG.Decoder.decoder)
                    |> Expect.equal (Ok g)
        ]
