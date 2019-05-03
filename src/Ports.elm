port module Ports exposing (backward, begin, end, forward, open, playPause)

import Json.Encode exposing (Value, object, string)


port toJs : Value -> Cmd msg


open : String -> Cmd msg
open file =
    toJs <| object [ ( "command", string "open" ), ( "file", string file ) ]


begin : Cmd msg
begin =
    toJs <| object [ ( "command", string "begin" ) ]


backward : Cmd msg
backward =
    toJs <| object [ ( "command", string "backward" ) ]


playPause : Cmd msg
playPause =
    toJs <| object [ ( "command", string "playPause" ) ]


forward : Cmd msg
forward =
    toJs <| object [ ( "command", string "forward" ) ]


end : Cmd msg
end =
    toJs <| object [ ( "command", string "end" ) ]
