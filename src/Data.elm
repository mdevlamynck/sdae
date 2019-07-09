module Data exposing (FileResource(..), Game, Hit(..), Input, Kind(..), Level(..), Player(..), Raw, Song, Stage, compareInput, emptyGame, emptyInput, mapResource)

import Bytes exposing (Bytes)
import EverySet exposing (EverySet)
import Pivot exposing (Pivot)
import TimeArray exposing (TimeArray)


type FileResource f
    = None
    | Loading f
    | Loaded f
    | FailedToLoad


mapResource : (a -> b) -> FileResource a -> FileResource b
mapResource f res =
    case res of
        Loaded r ->
            Loaded (f r)

        Loading r ->
            Loading (f r)

        FailedToLoad ->
            FailedToLoad

        None ->
            None


type alias Song =
    { name : String
    }


type alias Game =
    { stages : Pivot Stage
    , raw : Maybe Raw
    }


type alias Raw =
    { head : Bytes
    , blocks : List Bytes
    }


type alias Stage =
    { level : Level
    , player : Player
    , maxScore : Int
    , inputs : TimeArray Input
    }


type Level
    = Easy
    | Normal
    | Hard
    | SuperHard


type Player
    = P1
    | P2


type alias Input =
    { hits : EverySet Hit
    , pos : Int
    , offset : Int
    , duration : Int
    , kind : Kind
    }


type Hit
    = LeftUp
    | LeftMiddle
    | LeftDown
    | RightUp
    | RightMiddle
    | RightDown


type Kind
    = Regular
    | Long
    | Pose


emptyGame : Game
emptyGame =
    { stages =
        Pivot.fromCons
            ( Easy, P1 )
            [ ( Easy, P2 )
            , ( Normal, P1 )
            , ( Normal, P2 )
            , ( Hard, P1 )
            , ( Hard, P2 )
            , ( SuperHard, P1 )
            , ( SuperHard, P2 )
            ]
            |> Pivot.mapA
                (\( l, p ) ->
                    { level = l
                    , player = p
                    , maxScore = 0
                    , inputs = TimeArray.empty compareInput
                    }
                )
    , raw = Nothing
    }


emptyInput : Int -> Input
emptyInput pos =
    { hits = EverySet.empty
    , pos = pos
    , offset = 3
    , duration = 0
    , kind = Regular
    }


compareInput : Int -> Input -> Order
compareInput frame input =
    if frame < input.pos - input.offset then
        LT

    else if frame > input.pos + input.offset + input.duration then
        GT

    else
        EQ
