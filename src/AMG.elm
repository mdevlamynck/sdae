module AMG exposing (decode, encode)

import Bytes exposing (Bytes, Endianness(..))
import Bytes.Encode as E
import Bytes.Parser as P exposing (Step(..))
import Data exposing (Game)


type alias Inputs =
    { level : Level
    , player : Player
    , maxScore : Int
    , inputs : List Input
    }


type alias Input =
    {}


type Level
    = Easy
    | Normal
    | Hard
    | SuperHard
    | AltEasy
    | AltNormal
    | AltHard
    | AltSuperHard


type Player
    = P1
    | P2



-- Decoder


type alias Parser a =
    P.Parser String () a


decode : Bytes -> Maybe Game
decode =
    P.run decoder
        >> Result.toMaybe


decoder : Parser Game
decoder =
    P.succeed {}
        |> P.ignore (block "HEAD")
        |> P.ignore body


body : Parser ()
body =
    P.loop bodyHelper ()


bodyHelper : () -> Parser (Step () ())
bodyHelper state =
    P.oneOf
        [ P.succeed (Loop state)
            |> P.ignore inputs
        , P.succeed (Loop state)
            |> P.ignore
                (P.oneOf
                    [ block "ACT_"
                    , block "CAM_"
                    , block "ONSH"
                    ]
                )
        , P.succeed (Done state)
            |> P.ignore (keyword "END_")
        ]


inputs : Parser Inputs
inputs =
    P.string 4
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
                            case P.run (inputsBody level) bytes of
                                Ok value ->
                                    P.succeed value

                                Err error ->
                                    P.fail ()
                        )
            )


inputsBody : Level -> Parser Inputs
inputsBody level =
    P.succeed (Inputs level)
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
        |> P.keep (dword |> P.andThen (P.repeat input))


input : Parser Input
input =
    P.succeed {}
        |> P.ignore dword
        |> P.ignore dword


block : String -> Parser ()
block blockName =
    P.succeed ()
        |> P.ignore (keyword blockName)
        |> P.ignore (dword |> P.andThen P.bytes)


keyword : String -> Parser ()
keyword str =
    P.string 4
        |> P.andThen
            (\parsed ->
                if parsed == str then
                    P.succeed ()

                else
                    P.fail ()
            )


dword : Parser Int
dword =
    P.unsignedInt32 LE


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
