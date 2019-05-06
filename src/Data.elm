module Data exposing (FileResource(..), Game, Hit(..), Input, Song)

import EverySet exposing (EverySet)
import File exposing (File)


type FileResource f
    = None
    | Loading f
    | Loaded f
    | FailedToLoad


type alias Song =
    { name : String }


type alias Game =
    {}


type alias Input =
    { hits : EverySet Hit
    }


type Hit
    = LeftUp
    | LeftMiddle
    | LeftDown
    | RightUp
    | RightMiddle
    | RightDown
