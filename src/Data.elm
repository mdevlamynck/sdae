module Data exposing (Game, Hit(..), Input, Song)

import EverySet exposing (EverySet)
import File exposing (File)


type alias Song =
    { file : File
    , name : String
    }


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
