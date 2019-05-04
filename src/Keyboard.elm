module Keyboard exposing (Commands, commandDecoder, subscriptions)

import Browser.Events exposing (onKeyDown)
import Data exposing (Hit(..))
import Json.Decode exposing (Decoder, andThen, bool, fail, field, oneOf, string, succeed)
import Json.Decode.Pipeline exposing (custom, required)


type alias Commands msg =
    { playPause : msg
    , backward : msg
    , forward : msg
    , toggleHit : Hit -> msg
    , previousHit : msg
    , nextHit : msg
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
                    ( "Space", _, _ ) ->
                        succeed commands.playPause

                    ( "KeyF", _, _ ) ->
                        succeed <| commands.toggleHit LeftUp

                    ( "KeyD", _, _ ) ->
                        succeed <| commands.toggleHit LeftMiddle

                    ( "KeyS", _, _ ) ->
                        succeed <| commands.toggleHit LeftDown

                    ( "KeyJ", _, _ ) ->
                        succeed <| commands.toggleHit RightUp

                    ( "KeyK", _, _ ) ->
                        succeed <| commands.toggleHit RightMiddle

                    ( "KeyL", _, _ ) ->
                        succeed <| commands.toggleHit RightDown

                    ( "ArrowLeft", _, _ ) ->
                        succeed <| commands.backward

                    ( "ArrowRight", _, _ ) ->
                        succeed <| commands.forward

                    ( "ArrowUp", _, _ ) ->
                        succeed <| commands.previousHit

                    ( "ArrowDown", _, _ ) ->
                        succeed <| commands.nextHit

                    ( _, "o", _ ) ->
                        succeed <| commands.openSong

                    ( _, "g", _ ) ->
                        succeed <| commands.openGame

                    ( _, "n", _ ) ->
                        succeed <| commands.newGame

                    ( _, "x", _ ) ->
                        succeed <| commands.exportGame

                    _ ->
                        fail ""
            )
