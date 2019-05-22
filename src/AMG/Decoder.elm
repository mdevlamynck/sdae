module AMG.Decoder exposing (decoder)

import AMG.Bitwise exposing (..)
import Bytes exposing (Bytes, Endianness(..))
import Bytes.Parser as P exposing (..)
import Data exposing (Game, Hit(..), Input, Kind(..), Level(..), Player(..), Stage)
import EverySet exposing (EverySet)


type alias Parser a =
    P.Parser String () a


decoder : Parser Game
decoder =
    succeed Game
        |> ignore (block "HEAD")
        |> keep body


body : Parser (List Stage)
body =
    inContext "body" <|
        loop bodyHelper []


bodyHelper : List Stage -> Parser (Step (List Stage) (List Stage))
bodyHelper state =
    oneOf
        [ succeed (\i -> Loop (i :: state))
            |> keep stage
        , succeed (Loop state)
            |> ignore
                (oneOf
                    [ block "ACT_"
                    , block "CAM_"
                    , block "ONSH"
                    ]
                )
        , succeed (Done (List.reverse state))
            |> ignore (keyword "END_")
        ]


stage : Parser Stage
stage =
    inContext "stage"
        (string 4
            |> andThen
                (\name ->
                    case name of
                        "EASY" ->
                            succeed Easy

                        "NORM" ->
                            succeed Normal

                        "HARD" ->
                            succeed Hard

                        "SUPR" ->
                            succeed SuperHard

                        "DA_E" ->
                            succeed AltEasy

                        "DA_N" ->
                            succeed AltNormal

                        "DA_H" ->
                            succeed AltHard

                        "DA_S" ->
                            succeed AltSuperHard

                        _ ->
                            fail ()
                )
            |> andThen
                (\level ->
                    dword
                        |> andThen bytes
                        |> andThen
                            (\bytes ->
                                run (stageBody level) bytes
                                    |> unwrapResult
                            )
                )
        )


stageBody : Level -> Parser Stage
stageBody level =
    succeed (Stage level)
        |> keep
            (dword
                |> andThen
                    (\player ->
                        case player of
                            0 ->
                                succeed P1

                            1 ->
                                succeed P2

                            _ ->
                                fail ()
                    )
            )
        |> keep dword
        |> keep
            (dword
                |> andThen (repeat input)
                |> map (List.filterMap identity)
            )


input : Parser (Maybe Input)
input =
    inContext "input"
        (succeed inputHelper
            |> keep dword
            |> keep dword
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
    inContext ("block " ++ blockName)
        (succeed ()
            |> ignore (keyword blockName)
            |> ignore (dword |> andThen bytes)
        )


keyword : String -> Parser ()
keyword str =
    inContext ("keyword " ++ str)
        (string 4
            |> andThen
                (\parsed ->
                    if parsed == str then
                        succeed ()

                    else
                        fail ()
                )
        )


dword : Parser Int
dword =
    inContext "dword" <|
        unsignedInt32 LE


unwrapMaybe : Maybe v -> Parser v
unwrapMaybe =
    Maybe.map succeed >> Maybe.withDefault (fail ())


unwrapResult : Result e v -> Parser v
unwrapResult =
    Result.map succeed >> Result.withDefault (fail ())
