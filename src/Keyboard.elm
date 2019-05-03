module Keyboard exposing (Commands, commandDecoder, subscriptions)

import Browser.Events exposing (onKeyDown)
import Data exposing (Hit(..))
import Json.Decode exposing (Decoder, andThen, fail, field, string, succeed)


type alias Commands msg =
    { playPause : msg
    , toggleHit : Hit -> msg
    }


subscriptions : Commands msg -> Sub msg
subscriptions commands =
    onKeyDown (commandDecoder commands)


commandDecoder : Commands msg -> Decoder msg
commandDecoder commands =
    field "code" string
        |> andThen
            (\key ->
                case Debug.log "" key of
                    "Space" ->
                        succeed commands.playPause

                    "KeyS" ->
                        succeed <| commands.toggleHit LeftDown

                    "KeyD" ->
                        succeed <| commands.toggleHit LeftMiddle

                    "KeyF" ->
                        succeed <| commands.toggleHit LeftUp

                    "KeyJ" ->
                        succeed <| commands.toggleHit RightDown

                    "KeyK" ->
                        succeed <| commands.toggleHit RightMiddle

                    "KeyL" ->
                        succeed <| commands.toggleHit RightUp

                    _ ->
                        fail ""
            )
