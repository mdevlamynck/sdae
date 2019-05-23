module Data exposing (FileResource(..), Game, Hit(..), Input, Kind(..), Level(..), Player(..), Song, Stage)

import Bytes exposing (Bytes)
import Bytes.Encode as E
import EverySet exposing (EverySet)


type FileResource f
    = None
    | Loading f
    | Loaded f
    | FailedToLoad


type alias Song =
    { name : String
    }


type alias Game =
    { stages : List Stage
    , head : Bytes
    , act : Bytes
    , cam : Bytes
    , onsh : Bytes
    }


type alias Stage =
    { level : Level
    , player : Player
    , maxScore : Int
    , inputs : List Input
    }


type Level
    = Easy
    | Normal
    | Hard
    | SuperHard
    | HustleEasy
    | HustleNormal
    | HustleHard
    | HustleSuperHard


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
