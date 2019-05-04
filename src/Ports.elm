port module Ports exposing (backward, begin, end, forward, load, playPause, seek, subscriptions, unload)

import Json.Decode as D exposing (Decoder, andThen, decodeValue, fail, field)
import Json.Decode.Pipeline exposing (required)
import Json.Encode as E exposing (Value, bool, float, object, string)


port toJs : Value -> Cmd msg


load : String -> Cmd msg
load song =
    toJs <|
        object
            [ ( "command", string "load" )
            , ( "song", string song )
            ]


unload : Cmd msg
unload =
    toJs <| object [ ( "command", string "unload" ) ]


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


seek : Float -> Cmd msg
seek pos =
    toJs <|
        object
            [ ( "command", string "seek" )
            , ( "pos", float pos )
            ]


port toElm : (Value -> msg) -> Sub msg


type alias Commands msg =
    { invalidCommand : msg
    , isPlaying : Bool -> msg
    , songLoaded : Float -> msg
    , pos : Float -> msg
    }


subscriptions : Commands msg -> Sub msg
subscriptions commands =
    toElm (decodeValue (commandDecoder commands) >> Result.withDefault commands.invalidCommand)


commandDecoder : Commands msg -> Decoder msg
commandDecoder commands =
    field "command" D.string
        |> andThen
            (\command ->
                case command of
                    "isPlaying" ->
                        D.succeed commands.isPlaying
                            |> required "isPlaying" D.bool

                    "songLoaded" ->
                        D.succeed commands.songLoaded
                            |> required "duration" D.float

                    "pos" ->
                        D.succeed commands.pos
                            |> required "pos" D.float

                    _ ->
                        fail ""
            )
