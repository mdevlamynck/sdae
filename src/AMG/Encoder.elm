module AMG.Encoder exposing (dword, emptyHead, encoder)

import AMG.Bitwise exposing (..)
import Bytes exposing (..)
import Bytes.Encode exposing (..)
import Data exposing (..)
import EverySet exposing (EverySet)
import List.Extra as List
import Pivot
import TimeArray


encoder : Game -> Encoder
encoder game =
    let
        ( head, blocks ) =
            case game.raw of
                Just raw ->
                    ( emptyHead, raw.blocks )

                Nothing ->
                    ( emptyHead, [] )
    in
    sequence
        [ bytes head
        , stages game
        , sequence (List.map bytes blocks)
        , end
        ]


emptyHead : Bytes
emptyHead =
    encode <| block "HEAD" empty


stages : Game -> Encoder
stages game =
    sequence <|
        List.map stage (Pivot.toList game.stages)


stage : Stage -> Encoder
stage s =
    let
        level =
            case s.level of
                Easy ->
                    "EASY"

                Normal ->
                    "NORM"

                Hard ->
                    "HARD"

                SuperHard ->
                    "SUPR"

        player =
            case s.player of
                P1 ->
                    0

                P2 ->
                    1

        kind i =
            case i.kind of
                Long ->
                    2

                _ ->
                    1

        inputs =
            TimeArray.toList s.inputs
    in
    block level <|
        sequence
            [ dword player
            , dword s.maxScore
            , dword (inputs |> List.map kind |> List.sum)
            , sequence <|
                List.map input inputs
            ]


block : String -> Encoder -> Encoder
block name body =
    let
        bodySize =
            width (encode body)

        paddingSize =
            case modBy 16 (bodySize + 8) of
                0 ->
                    0

                n ->
                    16 - n
    in
    sequence
        [ string name
        , sequence
            [ dword (bodySize + paddingSize)
            , body
            , sequence (List.repeat paddingSize (u8 0))
            ]
        ]


input : Input -> Encoder
input i =
    case i.kind of
        Regular ->
            sequence
                [ dword i.pos
                , dword (cmd KindRegular i.hits)
                ]

        Pose ->
            sequence
                [ dword i.pos
                , dword (cmd KindPose i.hits)
                ]

        Long ->
            sequence
                [ dword i.pos
                , dword (cmd KindLongStart i.hits)
                , dword (i.pos + i.duration)
                , dword (cmd KindLongEnd i.hits)
                ]


type Kind
    = KindRegular
    | KindPose
    | KindLongStart
    | KindLongEnd


cmd : Kind -> EverySet Hit -> Int
cmd kind hits =
    (case kind of
        KindRegular ->
            1

        KindPose ->
            4

        KindLongStart ->
            3

        KindLongEnd ->
            8
    )
        |> set 4 (EverySet.member LeftUp hits)
        |> set 5 (EverySet.member LeftMiddle hits)
        |> set 6 (EverySet.member LeftDown hits)
        |> set 7 (EverySet.member RightUp hits)
        |> set 8 (EverySet.member RightMiddle hits)
        |> set 9 (EverySet.member RightDown hits)


end : Encoder
end =
    string "END_"


u8 : Int -> Encoder
u8 =
    unsignedInt8


dword : Int -> Encoder
dword =
    unsignedInt32 LE


empty : Encoder
empty =
    sequence []
