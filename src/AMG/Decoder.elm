module AMG.Decoder exposing (decoder)

import AMG.Bitwise exposing (..)
import AMG.Encoder as E
import Bytes exposing (Bytes, Endianness(..))
import Bytes.Encode as E
import Bytes.Parser as P exposing (..)
import Data exposing (Game, Hit(..), Input, Kind(..), Level(..), Player(..), Stage, compareInput)
import EverySet exposing (EverySet)
import TimeArray


type alias Parser a =
    P.Parser String () a


type alias File =
    { stages : List Stage
    , head : Bytes
    , blocks : List Bytes
    }


type alias Command =
    { hits : EverySet Hit
    , kind : Kind
    }


type Kind
    = KindRegular Int
    | KindPose Int
    | KindLongStart Int
    | KindLongEnd Int


decoder : Parser Game
decoder =
    block "HEAD"
        |> map
            (\head ->
                { stages = []
                , head = head
                , blocks = []
                }
            )
        |> andThen body
        |> andThen fileToGame


fileToGame : File -> Parser Game
fileToGame file =
    succeed
        { stages = file.stages
        , raw =
            Just
                { head = file.head
                , blocks = file.blocks
                }
        }


body : File -> Parser File
body game =
    inContext "body" <|
        loop bodyHelper game


bodyHelper : File -> Parser (Step File File)
bodyHelper state =
    oneOf
        [ succeed (\i -> Loop { state | stages = i :: state.stages })
            |> keep stage
        , succeed (\b -> Loop { state | blocks = b :: state.blocks })
            |> keep
                (oneOf
                    [ block "ACT_"
                    , block "CAM_"
                    , block "ONSH"
                    , block "DA_E"
                    , block "DA_N"
                    , block "DA_H"
                    , block "DA_S"
                    ]
                )
        , succeed (Done { state | stages = List.reverse state.stages, blocks = List.reverse state.blocks })
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
                |> andThen (repeat command)
                |> map (List.foldl commandsToInputs ( Nothing, [] ) >> Tuple.second >> List.reverse >> TimeArray.fromList compareInput)
            )


commandsToInputs : Maybe Command -> ( Maybe Command, List Input ) -> ( Maybe Command, List Input )
commandsToInputs maybeCmd acc =
    case ( maybeCmd, acc ) of
        ( Just cmd, ( maybePreviousCmd, inputs ) ) ->
            case cmd.kind of
                KindRegular pos ->
                    ( maybeCmd
                    , { hits = cmd.hits
                      , pos = pos
                      , offset = 3
                      , duration = 0
                      , kind = Regular
                      }
                        :: inputs
                    )

                KindPose pos ->
                    ( maybeCmd
                    , { hits = cmd.hits
                      , pos = pos
                      , offset = 3
                      , duration = 60
                      , kind = Pose
                      }
                        :: inputs
                    )

                KindLongEnd end ->
                    case maybePreviousCmd of
                        Just previousCmd ->
                            case previousCmd.kind of
                                KindLongStart start ->
                                    ( maybeCmd
                                    , { hits = previousCmd.hits
                                      , pos = start
                                      , offset = 3
                                      , duration = end - start
                                      , kind = Long
                                      }
                                        :: inputs
                                    )

                                _ ->
                                    ( maybeCmd, inputs )

                        _ ->
                            ( maybeCmd, inputs )

                _ ->
                    ( maybeCmd, inputs )

        ( _, ( _, inputs ) ) ->
            ( maybeCmd, inputs )


command : Parser (Maybe Command)
command =
    inContext "command"
        (succeed commandHelper
            |> keep dword
            |> keep dword
            |> andThen identity
        )


commandHelper : Int -> Int -> Parser (Maybe Command)
commandHelper pos cmd =
    let
        with predicate value =
            if predicate then
                Just value

            else
                Nothing

        maybeKind =
            case u4 0 cmd of
                1 ->
                    Just (KindRegular pos)

                4 ->
                    Just (KindPose pos)

                3 ->
                    Just (KindLongStart pos)

                8 ->
                    Just (KindLongEnd pos)

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
            succeed (Just { hits = hits, kind = kind })

        _ ->
            succeed Nothing


block : String -> Parser Bytes
block blockName =
    inContext ("block " ++ blockName)
        (succeed (\n ( s, b ) -> E.encode (E.sequence [ E.string n, E.dword s, E.bytes b ]))
            |> keep (keyword blockName)
            |> keep (dword |> andThen (\s -> bytes s |> map (\b -> ( s, b ))))
        )


keyword : String -> Parser String
keyword str =
    inContext ("keyword " ++ str)
        (string 4
            |> andThen
                (\parsed ->
                    if parsed == str then
                        succeed str

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
