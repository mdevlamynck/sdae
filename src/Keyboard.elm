module Keyboard exposing (Commands, Mode(..), commandDecoder, subscriptions)

import Browser.Events exposing (onKeyDown)
import Inputs exposing (Hit(..), Kind(..))
import Json.Decode exposing (Decoder, andThen, bool, fail, field, oneOf, string, succeed)
import Json.Decode.Pipeline exposing (custom, required)


type Mode
    = NormalMode
    | PropertyMode


type alias Commands msg =
    { -- Normal Mode
      playPause : msg
    , backward : msg
    , forward : msg
    , toggleHit : Hit -> msg
    , previousInput : msg
    , nextInput : msg
    , deleteCurrentInput : msg
    , undo : msg
    , redo : msg
    , setKind : Kind -> msg
    , mode : Mode -> msg

    -- Property Mode
    , openSong : msg
    , openGame : msg
    , newGame : msg
    , exportGame : msg
    }


subscriptions : Mode -> Commands msg -> Sub msg
subscriptions mode commands =
    onKeyDown (commandDecoder mode commands)


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


commandDecoder : Mode -> Commands msg -> Decoder msg
commandDecoder mode commands =
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
                case mode of
                    NormalMode ->
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

                            ( "KeyU", _, None ) ->
                                succeed <| commands.setKind Regular

                            ( "KeyI", _, None ) ->
                                succeed <| commands.setKind Long

                            ( "KeyO", _, None ) ->
                                succeed <| commands.setKind Pose

                            ( "ArrowLeft", _, None ) ->
                                succeed <| commands.backward

                            ( "ArrowRight", _, None ) ->
                                succeed <| commands.forward

                            ( "ArrowUp", _, None ) ->
                                succeed <| commands.previousInput

                            ( "ArrowDown", _, None ) ->
                                succeed <| commands.nextInput

                            ( _, "x", None ) ->
                                succeed <| commands.deleteCurrentInput

                            ( _, "z", None ) ->
                                succeed <| commands.undo

                            ( _, "y", None ) ->
                                succeed <| commands.redo

                            ( _, "p", None ) ->
                                succeed <| commands.mode PropertyMode

                            _ ->
                                fail ""

                    PropertyMode ->
                        case ( code, key, modifier ) of
                            ( _, "o", None ) ->
                                succeed <| commands.openSong

                            ( _, "g", None ) ->
                                succeed <| commands.openGame

                            ( _, "n", None ) ->
                                succeed <| commands.newGame

                            ( _, "x", None ) ->
                                succeed <| commands.exportGame

                            ( "Escape", _, None ) ->
                                succeed <| commands.mode NormalMode

                            _ ->
                                fail ""
            )
