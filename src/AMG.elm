module AMG exposing (decode, encode)

import AMG.Decoder exposing (decoder)
import AMG.Encoder exposing (encoder)
import Bytes exposing (Bytes)
import Bytes.Encode as E
import Bytes.Parser as P
import Data exposing (Game)


decode : Bytes -> Maybe Game
decode =
    P.run decoder
        >> Result.toMaybe


encode : Game -> Bytes
encode game =
    E.encode (encoder game)
