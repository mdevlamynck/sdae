module AMG exposing (decode, encode)

import Bitwise exposing (and, shiftLeftBy, shiftRightBy)
import Bytes exposing (Bytes, Endianness(..))
import Bytes.Encode as E
import Bytes.Parser as P exposing (Step(..))
import Data exposing (Game, Hit(..), Input, Kind(..), Level(..), Player(..), Stage)
import EverySet exposing (EverySet)



-- Decoder


type alias Parser a =
    P.Parser String () a


decode : Bytes -> Maybe Game
decode =
    P.run decoder
        >> Result.toMaybe


decoder : Parser Game
decoder =
    P.succeed Game
        |> P.ignore (block "HEAD")
        |> P.keep body


body : Parser (List Stage)
body =
    P.inContext "body" <|
        P.loop bodyHelper []


bodyHelper : List Stage -> Parser (Step (List Stage) (List Stage))
bodyHelper state =
    P.oneOf
        [ P.succeed (\i -> Loop (i :: state))
            |> P.keep stage
        , P.succeed (Loop state)
            |> P.ignore
                (P.oneOf
                    [ block "ACT_"
                    , block "CAM_"
                    , block "ONSH"
                    ]
                )
        , P.succeed (Done (List.reverse state))
            |> P.ignore (keyword "END_")
        ]


stage : Parser Stage
stage =
    P.inContext "stage"
        (P.string 4
            |> P.andThen
                (\name ->
                    case name of
                        "EASY" ->
                            P.succeed Easy

                        "NORM" ->
                            P.succeed Normal

                        "HARD" ->
                            P.succeed Hard

                        "SUPR" ->
                            P.succeed SuperHard

                        "DA_E" ->
                            P.succeed AltEasy

                        "DA_N" ->
                            P.succeed AltNormal

                        "DA_H" ->
                            P.succeed AltHard

                        "DA_S" ->
                            P.succeed AltSuperHard

                        _ ->
                            P.fail ()
                )
            |> P.andThen
                (\level ->
                    dword
                        |> P.andThen P.bytes
                        |> P.andThen
                            (\bytes ->
                                P.run (stageBody level) bytes
                                    |> unwrapResult
                            )
                )
        )


stageBody : Level -> Parser Stage
stageBody level =
    P.succeed (Stage level)
        |> P.keep
            (dword
                |> P.andThen
                    (\player ->
                        case player of
                            0 ->
                                P.succeed P1

                            1 ->
                                P.succeed P2

                            _ ->
                                P.fail ()
                    )
            )
        |> P.keep dword
        |> P.keep
            (dword
                |> P.andThen (P.repeat input)
                |> P.map (List.filterMap identity)
            )


input : Parser (Maybe Input)
input =
    P.inContext "input"
        (P.succeed inputHelper
            |> P.keep dword
            |> P.keep dword
        )


inputHelper : Int -> Int -> Maybe Input
inputHelper pos cmd =
    let
        with predicate value =
            if predicate then
                Just value

            else
                Nothing

        maybeKind =
            case u4 0 cmd of
                1 ->
                    Just Regular

                _ ->
                    Nothing

        hits =
            [ with (bit 4 cmd) LeftUp
            , with (bit 5 cmd) LeftMiddle
            , with (bit 6 cmd) LeftDown
            , with (bit 7 cmd) RightUp
            , with (bit 8 cmd) RightMiddle
            , with (bit 9 cmd) RightDown
            ]
                |> List.filterMap identity
                |> EverySet.fromList
    in
    case maybeKind of
        Just kind ->
            Just { hits = hits, pos = toFloat pos / 60, duration = 0.1, kind = kind }

        _ ->
            Nothing


block : String -> Parser ()
block blockName =
    P.inContext ("block " ++ blockName)
        (P.succeed ()
            |> P.ignore (keyword blockName)
            |> P.ignore (dword |> P.andThen P.bytes)
        )


keyword : String -> Parser ()
keyword str =
    P.inContext ("keyword " ++ str)
        (P.string 4
            |> P.andThen
                (\parsed ->
                    if parsed == str then
                        P.succeed ()

                    else
                        P.fail ()
                )
        )


bit : Int -> Int -> Bool
bit offset u32 =
    u32
        |> shiftRightBy offset
        |> and 0x01
        |> (==) 1


u4 : Int -> Int -> Int
u4 offset u32 =
    u32
        |> and 0x0F


dword : Parser Int
dword =
    P.inContext "dword" <|
        P.unsignedInt32 LE


unwrapMaybe : Maybe v -> Parser v
unwrapMaybe =
    Maybe.map P.succeed >> Maybe.withDefault (P.fail ())


unwrapResult : Result e v -> Parser v
unwrapResult =
    Result.map P.succeed >> Result.withDefault (P.fail ())


assert : (v -> Bool) -> v -> Parser v
assert assertion value =
    if assertion value then
        P.succeed value

    else
        P.fail ()



-- Encoder


encode : Game -> Bytes
encode game =
    E.encode <| E.sequence []
