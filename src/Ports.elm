port module Ports exposing (backward, begin, end, forward, load, playPause)

import Json.Encode exposing (Value, bool, object, string)


port toJs : Value -> Cmd msg


load : String -> Cmd msg
load song =
    toJs <|
        object
            [ ( "command", string "load" )
            , ( "song", string song )
            ]


begin : Cmd msg
begin =
    toJs <| object [ ( "command", string "begin" ) ]


backward : Cmd msg
backward =
    toJs <| object [ ( "command", string "backward" ) ]


playPause : Bool -> Cmd msg
playPause isPlaying =
    toJs <|
        object
            [ ( "command", string "playPause" )
            , ( "isPlaying", bool isPlaying )
            ]


forward : Cmd msg
forward =
    toJs <| object [ ( "command", string "forward" ) ]


end : Cmd msg
end =
    toJs <| object [ ( "command", string "end" ) ]
