module Main exposing (main)

import AMG
import Browser
import Bytes exposing (Bytes)
import Data exposing (FileResource(..), Game, Hit(..), Input, Song)
import Element exposing (..)
import Element.Background as Background
import Element.Border as Border
import Element.Font as Font
import Element.Input exposing (button, labelHidden, slider, thumb)
import Element.Region exposing (aside, mainContent, navigation)
import Element.Utils exposing (checked, elWhenJust)
import EverySet exposing (EverySet)
import File exposing (File)
import File.Download as Download
import File.Select as Select
import Html exposing (Html)
import Keyboard
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
    , song : FileResource Song

    -- Game File
    , game : FileResource Game

    -- Inputs
    , inputs : List Input
    }


type Msg
    = MsgNoOp
      -- Commands
    | MsgIsPlaying Bool
    | MsgSongLoaded Float
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
    | MsgToggleHit Hit
      -- Song
    | MsgSelectSong
    | MsgUnloadSong
    | MsgSongSelected File
    | MsgSongContent String
      -- Song
    | MsgNewGame
    | MsgSelectGame
    | MsgUnloadGame
    | MsgExportGame
    | MsgGameSelected File
    | MsgGameLoaded Bytes
      -- Cypress
    | MsgCypressLoadSong String String



-- Logic


init : Flags -> ( Model, Cmd Msg )
init _ =
    ( { inputs = []
      , isPlaying = False
      , pos = 0
      , duration = 0
      , currentInput =
            Just
                { hits = EverySet.empty
                }
      , song = None
      , game = None
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

        MsgSongLoaded duration ->
            ( { model
                | duration = duration
                , song =
                    case model.song of
                        Loading file ->
                            Loaded file

                        resource ->
                            resource
              }
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
            ( model
                |> (mapCurrentInput << mapInputHits)
                    (EverySet.insert hit)
            , Cmd.none
            )

        MsgRemoveHit hit ->
            ( model
                |> (mapCurrentInput << mapInputHits)
                    (EverySet.remove hit)
            , Cmd.none
            )

        MsgToggleHit hit ->
            ( model
                |> (mapCurrentInput << mapInputHits)
                    (\hits ->
                        if EverySet.member hit hits then
                            EverySet.remove hit hits

                        else
                            EverySet.insert hit hits
                    )
            , Cmd.none
            )

        MsgSelectSong ->
            ( model
            , Select.file [] MsgSongSelected
            )

        MsgUnloadSong ->
            ( { model | song = None }
            , Ports.unload
            )

        MsgSongSelected file ->
            ( { model | song = Loading { name = File.name file } }
            , Task.perform MsgSongContent (File.toUrl file)
            )

        MsgSongContent songBase64 ->
            ( model
            , Ports.load songBase64
            )

        MsgNewGame ->
            ( { model | game = Loaded {} }
            , Cmd.none
            )

        MsgSelectGame ->
            ( model
            , Select.file [] MsgGameSelected
            )

        MsgUnloadGame ->
            ( { model | game = None }
            , Cmd.none
            )

        MsgExportGame ->
            case model.game of
                Loaded game ->
                    ( model
                    , Download.bytes "song.AMG" "application/octet-stream" (AMG.encode game)
                    )

                _ ->
                    ( model
                    , Cmd.none
                    )

        MsgGameSelected file ->
            ( model
            , Task.perform MsgGameLoaded (File.toBytes file)
            )

        MsgGameLoaded bytes ->
            case AMG.decode bytes of
                Just game ->
                    ( { model | game = Loaded game }
                    , Cmd.none
                    )

                Nothing ->
                    ( { model | game = FailedToLoad }
                    , Cmd.none
                    )

        MsgCypressLoadSong name content ->
            ( { model | song = Loading { name = name } }
            , Ports.load content
            )


subscriptions : Model -> Sub Msg
subscriptions model =
    let
        openSong =
            case model.song of
                None ->
                    MsgSelectSong

                _ ->
                    MsgUnloadSong

        openGame =
            case model.game of
                None ->
                    MsgSelectGame

                _ ->
                    MsgUnloadGame
    in
    Sub.batch
        [ Ports.subscriptions
            { invalidCommand = MsgNoOp
            , isPlaying = MsgIsPlaying
            , songLoaded = MsgSongLoaded
            , pos = MsgPos
            }
        , Keyboard.subscriptions
            { playPause = MsgPlayPause
            , backward = MsgBackward
            , forward = MsgForward
            , toggleHit = MsgToggleHit
            , previousHit = MsgNoOp
            , nextHit = MsgNoOp
            , openSong = openSong
            , openGame = openGame
            , newGame = MsgNewGame
            , exportGame = MsgExportGame
            }
        , Ports.cypressSubscriptions
            { invalidCommand = MsgNoOp
            , loadSong = MsgCypressLoadSong
            }
        ]


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
    column [ height fill, width (shrink |> minimum 200), centerX, aside ] <|
        List.map inputRowView model.inputs


inputRowView : Input -> Element Msg
inputRowView model =
    text "input row"


playerView : Model -> Element Msg
playerView model =
    column [ width fill, spacing 20, paddingXY 0 20, navigation ]
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
    el [ width (fill |> maximum 400), height (fill |> maximum 400), centerX, centerY, mainContent ] <|
        elWhenJust model.currentInput <|
            \input ->
                column [ width fill, height fill, centerX, centerY ]
                    [ row [ width fill, height fill, centerX, centerY ]
                        [ el [ width (fillPortion 1) ] none
                        , hitButton LeftUp input
                        , hitButton RightUp input
                        , el [ width (fillPortion 1) ] none
                        ]
                    , row [ width fill, height fill, centerX, centerY ]
                        [ hitButton LeftMiddle input
                        , el [ width (fillPortion 2) ] none
                        , hitButton RightMiddle input
                        ]
                    , row [ width fill, height fill, centerX, centerY ]
                        [ el [ width (fillPortion 1) ] none
                        , hitButton LeftDown input
                        , hitButton RightDown input
                        , el [ width (fillPortion 1) ] none
                        ]
                    ]


hitButton : Hit -> Input -> Element Msg
hitButton hit input =
    let
        key =
            case hit of
                LeftUp ->
                    "f"

                LeftMiddle ->
                    "d"

                LeftDown ->
                    "s"

                RightUp ->
                    "j"

                RightMiddle ->
                    "k"

                RightDown ->
                    "l"
    in
    if EverySet.member hit input.hits then
        button
            [ width (fillPortion 2)
            , height (fillPortion 2)
            , centerX
            , centerY
            , Background.color <| rgb 0.5 0.5 0.5
            , Font.color <| rgb 0.1 0.1 0.1
            , Font.center
            , Font.size 20
            , checked True
            ]
            { onPress = Just (MsgRemoveHit hit)
            , label = text key
            }

    else
        button
            [ width (fillPortion 2)
            , height (fillPortion 2)
            , centerX
            , centerY
            , Background.color <| rgb 0.2 0.2 0.2
            , Font.color <| rgb 0.9 0.9 0.9
            , Font.center
            , Font.size 20
            , checked False
            ]
            { onPress = Just (MsgAddHit hit)
            , label = text key
            }


propertiesView : Model -> Element Msg
propertiesView model =
    column [ height fill, width (shrink |> minimum 300), centerX, spacing 5, aside ]
        [ songPropertiesView model.song
        , gamePropertiesView model.game
        ]


songPropertiesView : FileResource Song -> Element Msg
songPropertiesView resource =
    case resource of
        None ->
            el [ paddingXY 0 30, centerX ] <|
                button [ centerX, padding 20, Background.color buttonColor, Border.rounded 5 ]
                    { onPress = Just MsgSelectSong
                    , label = text "o: Select Song"
                    }

        Loading _ ->
            el [ paddingXY 0 30, centerX ] <|
                text "Loading"

        Loaded song ->
            column [ paddingXY 0 30, centerX, spacing 10 ] <|
                [ el [ centerX ] <| text song.name
                , button [ centerX, padding 20, Background.color buttonColor, Border.rounded 5 ]
                    { onPress = Just MsgUnloadSong
                    , label = text "o: Unload Song"
                    }
                ]

        FailedToLoad ->
            none


gamePropertiesView : FileResource Game -> Element Msg
gamePropertiesView resource =
    case resource of
        None ->
            column [ paddingXY 0 30, centerX, spacing 10 ] <|
                [ button [ centerX, padding 20, Background.color buttonColor, Border.rounded 5 ]
                    { onPress = Just MsgSelectGame
                    , label = text "g: Select Game file"
                    }
                , button [ centerX, padding 20, Background.color buttonColor, Border.rounded 5 ]
                    { onPress = Just MsgNewGame
                    , label = text "n: New Game file"
                    }
                ]

        Loading _ ->
            el [ paddingXY 0 30, centerX ] <|
                text "Loading"

        Loaded game ->
            column [ paddingXY 0 30, centerX, spacing 10 ] <|
                [ button [ centerX, padding 20, Background.color buttonColor, Border.rounded 5 ]
                    { onPress = Just MsgExportGame
                    , label = text "x: Export Game"
                    }
                , button [ centerX, padding 20, Background.color buttonColor, Border.rounded 5 ]
                    { onPress = Just MsgUnloadGame
                    , label = text "g: Unload Game"
                    }
                ]

        FailedToLoad ->
            column [ paddingXY 0 30, centerX, spacing 10 ] <|
                [ button [ centerX, padding 20, Background.color buttonColor, Border.rounded 5 ]
                    { onPress = Just MsgSelectGame
                    , label = text "g: Select Game file"
                    }
                , button [ centerX, padding 20, Background.color buttonColor, Border.rounded 5 ]
                    { onPress = Just MsgNewGame
                    , label = text "n: New Game file"
                    }
                , el [ centerX ] <|
                    text "Failed to load"
                ]
