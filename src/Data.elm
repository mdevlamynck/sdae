module Data exposing (FileResource(..), Game, Song)


type FileResource f
    = None
    | Loading f
    | Loaded f
    | FailedToLoad


type alias Song =
    { name : String }


type alias Game =
    {}
