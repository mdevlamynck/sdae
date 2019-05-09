module Keyboard exposing (Commands, commandDecoder, subscriptions)

import Browser.Events exposing (onKeyDown)
import Inputs exposing (Hit(..))
import Json.Decode exposing (Decoder, andThen, bool, fail, field, oneOf, string, succeed)
import Json.Decode.Pipeline exposing (custom, required)


type alias Commands msg =
    { playPause : msg
    , backward : msg
    , forward : msg
    , toggleHit : Hit -> msg
    , previousInput : msg
    , nextInput : msg
    , openSong : msg
    , openGame : msg
    , newGame : msg
    , exportGame : msg
    }


subscriptions : Commands msg -> Sub msg
subscriptions commands =
    onKeyDown (commandDecoder commands)


type alias Input =
    { code : String
    , key : String
    , modifier : Modifier
    }


type Modifier
    = Alt
    | Ctrl
    | Meta
    | Shift
    | None


commandDecoder : Commands msg -> Decoder msg
commandDecoder commands =
    let
        isTrue value =
            bool
                |> andThen
                    (\b ->
                        if b then
                            succeed value

                        else
                            fail ""
                    )
    in
    succeed Input
        |> required "code" string
        |> required "key" string
        |> custom
            (oneOf
                [ field "altKey" (isTrue Alt)
                , field "ctrlKey" (isTrue Ctrl)
                , field "metaKey" (isTrue Meta)
                , field "shiftKey" (isTrue Shift)
                , succeed None
                ]
            )
        |> andThen
            (\{ code, key, modifier } ->
                case ( code, key, modifier ) of
                    ( "Space", _, None ) ->
                        succeed commands.playPause

                    ( "KeyF", _, None ) ->
                        succeed <| commands.toggleHit LeftUp

                    ( "KeyD", _, None ) ->
                        succeed <| commands.toggleHit LeftMiddle

                    ( "KeyS", _, None ) ->
                        succeed <| commands.toggleHit LeftDown

                    ( "KeyJ", _, None ) ->
                        succeed <| commands.toggleHit RightUp

                    ( "KeyK", _, None ) ->
                        succeed <| commands.toggleHit RightMiddle

                    ( "KeyL", _, None ) ->
                        succeed <| commands.toggleHit RightDown

                    ( "ArrowLeft", _, None ) ->
                        succeed <| commands.backward

                    ( "ArrowRight", _, None ) ->
                        succeed <| commands.forward

                    ( "ArrowUp", _, None ) ->
                        succeed <| commands.previousInput

                    ( "ArrowDown", _, None ) ->
                        succeed <| commands.nextInput

                    ( _, "o", None ) ->
                        succeed <| commands.openSong

                    ( _, "g", None ) ->
                        succeed <| commands.openGame

                    ( _, "n", None ) ->
                        succeed <| commands.newGame

                    ( _, "x", None ) ->
                        succeed <| commands.exportGame

                    _ ->
                        fail ""
            )
