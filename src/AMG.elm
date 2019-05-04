module AMG exposing (decode, encode)

import Bytes exposing (Bytes)
import Bytes.Decode as Bytes exposing (fail)
import Bytes.Encode as Bytes exposing (sequence)
import Data exposing (Game)


decode : Bytes -> Maybe Game
decode =
    Bytes.decode <| fail


encode : Game -> Bytes
encode game =
    Bytes.encode <| sequence []
