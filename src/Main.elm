module Main exposing (main)

import Browser
import Bytes exposing (Bytes)
import Element exposing (..)
import Element.Background as Background
import Element.Border as Border
import Element.Font as Font
import Element.Input exposing (button, labelHidden, slider, thumb)
import Element.Utils exposing (elWhenJust)
import EverySet exposing (EverySet)
import File exposing (File)
import File.Select as Select
import Html exposing (Html)
import Ports
import Task


main : Program Flags Model Msg
main =
    Browser.element
        { init = init
        , update = update
        , subscriptions = subscriptions
        , view = view
        }



-- Styles


buttonColor : Color
buttonColor =
    rgb255 59 136 195



-- Data


type alias Flags =
    {}


type alias Model =
    { -- Player
      isPlaying : Bool
    , pos : Float
    , duration : Float

    -- Editor
    , currentInput : Maybe Input

    -- Song
    , song : Maybe Song

    -- Game File
    , game : Game

    -- Inputs
    , inputs : List Input
    }


type alias Song =
    { file : File
    , name : String
    }


type alias Game =
    {}


type alias Input =
    { hits : EverySet Hit
    }


type Hit
    = LeftUp
    | LeftMiddle
    | LeftDown
    | RightUp
    | RightMiddle
    | RightDown


type Msg
    = MsgNoOp
      -- Commands
    | MsgIsPlaying Bool
    | MsgDuration Float
    | MsgPos Float
      -- Player
    | MsgBegin
    | MsgBackward
    | MsgPlayPause
    | MsgForward
    | MsgEnd
    | MsgSeek Float
      -- Editor
    | MsgAddHit Hit
    | MsgRemoveHit Hit
      -- Song
    | MsgSelectSong
    | MsgSongSelected File
    | MsgSongLoaded String
      -- Song
    | MsgSelectGame
    | MsgGameSelected File
    | MsgGameLoaded Bytes



-- Logic


init : Flags -> ( Model, Cmd Msg )
init _ =
    ( { inputs = []
      , isPlaying = False
      , pos = 0
      , duration = 0
      , currentInput =
            Just
                { hits = EverySet.fromList [ LeftUp, RightDown ]
                }
      , song = Nothing
      , game = {}
      }
    , Cmd.none
    )


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        MsgNoOp ->
            ( model
            , Cmd.none
            )

        MsgIsPlaying isPlaying ->
            ( { model | isPlaying = isPlaying }
            , Cmd.none
            )

        MsgDuration duration ->
            ( { model | duration = duration }
            , Cmd.none
            )

        MsgPos pos ->
            ( { model | pos = pos }
            , Cmd.none
            )

        MsgBegin ->
            ( model
            , Ports.begin
            )

        MsgBackward ->
            ( model
            , Ports.backward
            )

        MsgPlayPause ->
            ( model
            , Ports.playPause
            )

        MsgForward ->
            ( model
            , Ports.forward
            )

        MsgEnd ->
            ( model
            , Ports.end
            )

        MsgSeek pos ->
            ( model
            , Ports.seek pos
            )

        MsgAddHit hit ->
            ( model |> (mapCurrentInput << mapInputHits <| EverySet.insert hit)
            , Cmd.none
            )

        MsgRemoveHit hit ->
            ( model |> (mapCurrentInput << mapInputHits <| EverySet.remove hit)
            , Cmd.none
            )

        MsgSelectSong ->
            ( model
            , Select.file [] MsgSongSelected
            )

        MsgSongSelected file ->
            ( { model | song = Just { file = file, name = File.name file } }
            , Task.perform MsgSongLoaded (File.toUrl file)
            )

        MsgSongLoaded songBase64 ->
            ( model
            , Ports.load songBase64
            )

        MsgSelectGame ->
            ( model
            , Select.file [] MsgGameSelected
            )

        MsgGameSelected file ->
            ( model
            , Task.perform MsgGameLoaded (File.toBytes file)
            )

        MsgGameLoaded bytes ->
            ( model
            , Cmd.none
            )


subscriptions : Model -> Sub Msg
subscriptions model =
    Ports.subscriptions
        { invalidCommand = MsgNoOp
        , isPlaying = MsgIsPlaying
        , duration = MsgDuration
        , pos = MsgPos
        }


mapCurrentInput : (Input -> Input) -> Model -> Model
mapCurrentInput function model =
    { model | currentInput = model.currentInput |> Maybe.map function }


mapInputHits : (EverySet Hit -> EverySet Hit) -> Input -> Input
mapInputHits function input =
    { input | hits = function input.hits }



-- View


view : Model -> Html Msg
view model =
    layoutWith
        { options =
            [ focusStyle
                { borderColor = Nothing
                , backgroundColor = Nothing
                , shadow = Nothing
                }
            ]
        }
        [ Background.color (rgb 0.1 0.1 0.1)
        , Font.family [ Font.monospace ]
        , Font.size 14
        , Font.color (rgb 0.9 0.9 0.9)
        , width fill
        , height fill
        , padding 5
        ]
        (mainView model)


mainView : Model -> Element Msg
mainView model =
    row [ width fill, height fill, spacing 5 ]
        [ inputListView model
        , column [ width fill, height fill, spacing 5 ]
            [ playerView model
            , editorView model
            ]
        , propertiesView model
        ]


inputListView : Model -> Element Msg
inputListView model =
    column [ height fill, width (shrink |> minimum 200), centerX ] <|
        List.map inputRowView model.inputs


inputRowView : Input -> Element Msg
inputRowView model =
    text "input row"


playerView : Model -> Element Msg
playerView model =
    column [ width fill, spacing 20, paddingXY 0 20 ]
        [ row [ centerX, spacing 20, Font.size 30 ]
            [ beginBtn
            , backwardBtn
            , playPauseBtn model.isPlaying
            , forwardBtn
            , endBtn
            ]
        , progressBarView model
        ]


beginBtn : Element Msg
beginBtn =
    button []
        { onPress = Just MsgBegin
        , label = text "⏮"
        }


backwardBtn : Element Msg
backwardBtn =
    button []
        { onPress = Just MsgBackward
        , label = text "⏪"
        }


playPauseBtn : Bool -> Element Msg
playPauseBtn isPlaying =
    button []
        { onPress = Just MsgPlayPause
        , label =
            text <|
                if isPlaying then
                    "⏸"

                else
                    "⏯"
        }


forwardBtn : Element Msg
forwardBtn =
    button []
        { onPress = Just MsgForward
        , label = text "⏩"
        }


endBtn : Element Msg
endBtn =
    button []
        { onPress = Just MsgEnd
        , label = text "⏭"
        }


progressBarView : Model -> Element Msg
progressBarView model =
    el [ width fill ] <|
        slider [ Background.color buttonColor, Border.rounded 8 ]
            { onChange = MsgSeek
            , label = labelHidden "progress"
            , min = 0
            , max = model.duration
            , value = model.pos
            , thumb =
                thumb
                    [ Element.width (Element.px 20)
                    , Element.height (Element.px 20)
                    , Border.rounded 10
                    , Background.color (Element.rgb 1 1 1)
                    ]
            , step = Nothing
            }


editorView : Model -> Element Msg
editorView model =
    let
        label hit input =
            if EverySet.member hit input.hits then
                button
                    [ width (fillPortion 2)
                    , height (fillPortion 2)
                    , centerX
                    , centerY
                    , Font.center
                    , Background.color <| rgb 0.5 0.5 0.5
                    ]
                    { onPress = Just (MsgRemoveHit hit)
                    , label = none
                    }

            else
                button
                    [ width (fillPortion 2)
                    , height (fillPortion 2)
                    , centerX
                    , centerY
                    , Font.center
                    , Background.color <| rgb 0.2 0.2 0.2
                    ]
                    { onPress = Just (MsgAddHit hit)
                    , label = none
                    }
    in
    el [ width (fill |> maximum 400), height (fill |> maximum 400), centerX, centerY ] <|
        elWhenJust model.currentInput <|
            \input ->
                column [ width fill, height fill, centerX, centerY, Font.center ]
                    [ row [ width fill, height fill, centerX, centerY, Font.center ]
                        [ el [ width (fillPortion 1) ] none
                        , label LeftUp input
                        , label RightUp input
                        , el [ width (fillPortion 1) ] none
                        ]
                    , row [ width fill, height fill, centerX, centerY, Font.center ]
                        [ label LeftMiddle input
                        , el [ width (fillPortion 2) ] none
                        , label RightMiddle input
                        ]
                    , row [ width fill, height fill, centerX, centerY, Font.center ]
                        [ el [ width (fillPortion 1) ] none
                        , label LeftDown input
                        , label RightDown input
                        , el [ width (fillPortion 1) ] none
                        ]
                    ]


propertiesView : Model -> Element Msg
propertiesView model =
    column [ height fill, width (shrink |> minimum 300), centerX, spacing 5 ]
        [ case model.song of
            Nothing ->
                openSongView

            Just song ->
                songPropertiesView song
        , gamePropertiesView model.game
        ]


openSongView : Element Msg
openSongView =
    el [ paddingXY 0 30, centerX ] <|
        button [ centerX, padding 20, Background.color buttonColor, Border.rounded 5 ]
            { onPress = Just MsgSelectSong
            , label = text "Select Song"
            }


songPropertiesView : Song -> Element Msg
songPropertiesView song =
    el [ paddingXY 0 30, centerX ] <|
        text song.name


gamePropertiesView : Game -> Element Msg
gamePropertiesView game =
    el [ paddingXY 0 30, centerX ] <|
        button [ centerX, padding 20, Background.color buttonColor, Border.rounded 5 ]
            { onPress = Just MsgSelectGame
            , label = text "Select Game file"
            }
