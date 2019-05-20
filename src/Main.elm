module Main exposing (main)

import AMG
import Base64
import Browser
import Bytes exposing (Bytes)
import Data exposing (FileResource(..), Game, Hit(..), Input, Kind(..), Level(..), Player(..), Song, Stage)
import Element exposing (..)
import Element.Background as Background
import Element.Border as Border
import Element.Events exposing (onMouseEnter, onMouseLeave)
import Element.Font as Font
import Element.Input exposing (button, labelHidden, slider, thumb)
import Element.Lazy exposing (..)
import Element.Region exposing (aside, mainContent, navigation)
import Element.Utils exposing (attrWhen, checked, elWhen, tag)
import EverySet exposing (EverySet)
import File exposing (File)
import File.Download as Download
import File.Select as Select
import History exposing (History)
import Html exposing (Html)
import Inputs exposing (..)
import Keyboard exposing (Mode(..))
import Ports
import Round exposing (round)
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
    { -- Keyboard
      mode : Mode

    -- Player
    , isPlaying : Bool
    , pos : Float
    , duration : Float

    -- Editor
    , inputs : Inputs
    , history : History Inputs
    , hoveredInput : Maybe Input
    , currentInput : Maybe Input

    -- Song
    , song : FileResource Song

    -- Game File
    , game : FileResource Game
    , currentStage : Maybe Stage
    }


type Msg
    = MsgNoOp
      -- Keyboard
    | MsgSetMode Mode
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
    | MsgFocusInput Input
    | MsgRemoveInput Input
    | MsgRemoveCurrentInput
    | MsgPreviousInput
    | MsgNextInput
    | MsgUndo
    | MsgRedo
    | MsgOnHoverStart Input
    | MsgOnHoverEnd
    | MsgCurrentInputKind Kind
      -- Song
    | MsgSelectSong
    | MsgUnloadSong
    | MsgSongSelected File
    | MsgSongContent String
      -- Game
    | MsgNewGame
    | MsgSelectGame
    | MsgUnloadGame
    | MsgExportGame
    | MsgGameSelected File
    | MsgGameLoaded Bytes
    | MsgFocusStage Stage
      -- Cypress
    | MsgCypressLoadSong String String
    | MsgCypressLoadGame String



-- Logic


init : Flags -> ( Model, Cmd Msg )
init _ =
    ( { mode = NormalMode
      , isPlaying = False
      , pos = 0
      , duration = 0
      , inputs = empty
      , history = History.empty
      , hoveredInput = Nothing
      , currentInput = Nothing
      , song = None
      , game = None
      , currentStage = Nothing
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

        MsgSetMode mode ->
            ( { model | mode = mode }
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
            let
                inputs =
                    updatePos pos model.inputs
            in
            ( { model | pos = pos, inputs = inputs, currentInput = getCurrentInput inputs }
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
            ( model |> withHistory (mapCurrentInputHits (EverySet.insert hit))
            , Cmd.none
            )

        MsgRemoveHit hit ->
            ( model |> withHistory (mapCurrentInputHits (EverySet.remove hit))
            , Cmd.none
            )

        MsgRemoveInput input ->
            ( model |> withHistory (removeInput input)
            , Cmd.none
            )

        MsgRemoveCurrentInput ->
            ( model |> withHistory removeCurrentInput
            , Cmd.none
            )

        MsgToggleHit hit ->
            ( model |> withHistory (mapCurrentInputHits (toggleMember hit))
            , Cmd.none
            )

        MsgFocusInput input ->
            ( model
            , Ports.seek input.pos
            )

        MsgPreviousInput ->
            ( model
            , Ports.seek (getPreviousInputPos model.inputs |> Maybe.withDefault 0)
            )

        MsgNextInput ->
            ( model
            , Ports.seek (getNextInputPos model.inputs |> Maybe.withDefault model.duration)
            )

        MsgUndo ->
            model |> applyMoveInHistory (History.undo model.history)

        MsgRedo ->
            model |> applyMoveInHistory (History.redo model.history)

        MsgOnHoverStart input ->
            ( { model | hoveredInput = Just input }
            , Cmd.none
            )

        MsgOnHoverEnd ->
            ( { model | hoveredInput = Nothing }
            , Cmd.none
            )

        MsgCurrentInputKind kind ->
            ( model |> withHistory (mapCurrentInput (\input -> { input | kind = kind }))
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
            ( { model | game = Loaded { stages = [] } }
            , Cmd.none
            )

        MsgSelectGame ->
            ( model
            , Select.file [] MsgGameSelected
            )

        MsgUnloadGame ->
            ( { model | game = None, currentStage = Nothing }
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

        MsgFocusStage stage ->
            ( { model | currentStage = Just stage, inputs = Inputs.fromList stage.inputs }
            , Cmd.none
            )

        MsgCypressLoadSong name content ->
            ( { model | song = Loading { name = name } }
            , Ports.load content
            )

        MsgCypressLoadGame content ->
            case Base64.toBytes content of
                Just bytes ->
                    update (MsgGameLoaded bytes) model

                Nothing ->
                    ( model, Cmd.none )


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
        , Keyboard.subscriptions model.mode
            { playPause = MsgPlayPause
            , backward = MsgBackward
            , forward = MsgForward
            , toggleHit = MsgToggleHit
            , previousInput = MsgPreviousInput
            , nextInput = MsgNextInput
            , deleteCurrentInput = MsgRemoveCurrentInput
            , undo = MsgUndo
            , redo = MsgRedo
            , mode = MsgSetMode
            , openSong = openSong
            , openGame = openGame
            , newGame = MsgNewGame
            , exportGame = MsgExportGame
            , setKind = MsgCurrentInputKind
            }
        , Ports.cypressSubscriptions
            { invalidCommand = MsgNoOp
            , loadSong = MsgCypressLoadSong
            , loadGame = MsgCypressLoadGame
            }
        ]


withHistory : (Inputs -> Inputs) -> Model -> Model
withHistory function model =
    let
        inputs =
            function model.inputs
    in
    { model
        | inputs = inputs
        , history = History.record inputs model.history
    }


applyMoveInHistory : ( History Inputs, Maybe Inputs ) -> Model -> ( Model, Cmd Msg )
applyMoveInHistory ( history, maybeInputs ) model =
    let
        inputs =
            maybeInputs |> Maybe.withDefault empty
    in
    ( { model | inputs = inputs, history = history }
    , Ports.seek (getPos inputs)
    )



-- View


type alias ModelView =
    { inputs : InputView
    , player : PlayerView
    , editor : EditorView
    , song : SongView
    , game : GameView
    , status : StatusView
    }


type alias InputView =
    { inputs : Inputs
    , hoveredInput : Maybe Input
    , currentInput : Maybe Input
    }


type alias PlayerView =
    { isPlaying : Bool
    , pos : Float
    , duration : Float
    }


type alias EditorView =
    { currentInput : Maybe Input
    }


type alias SongView =
    { song : FileResource Song
    }


type alias GameView =
    { game : FileResource Game
    , currentStage : Maybe Stage
    }


type alias StatusView =
    { mode : Mode
    }


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
        (mainView
            { inputs =
                { inputs = model.inputs
                , hoveredInput = model.hoveredInput
                , currentInput = model.currentInput
                }
            , player =
                { isPlaying = model.isPlaying
                , pos = model.pos
                , duration = model.duration
                }
            , editor =
                { currentInput = model.currentInput
                }
            , song =
                { song = model.song
                }
            , game =
                { game = model.game
                , currentStage = model.currentStage
                }
            , status =
                { mode = model.mode
                }
            }
        )


mainView : ModelView -> Element Msg
mainView model =
    row [ width fill, height fill, padding 20, spacing 40 ]
        [ lazy inputListView model.inputs
        , column [ width fill, height fill, spacing 5 ]
            [ lazy playerView model.player
            , lazy editorView model.editor
            , lazy statusBar model.status
            ]
        , lazy2 propertiesView model.song model.game
        ]


inputListView : InputView -> Element Msg
inputListView model =
    column [ height fill, width (shrink |> minimum 200), scrollbars, aside, spacing 5 ] <|
        List.indexedMap (inputRowView model) (getInputs model.inputs)


inputRowView : InputView -> Int -> Input -> Element Msg
inputRowView model pos input =
    let
        isChecked =
            model.currentInput == Just input
    in
    row
        [ width fill
        , padding 5
        , tag ("hit " ++ String.fromInt (pos + 1))
        , checked isChecked
        , attrWhen isChecked (Background.color buttonColor)
        , onMouseEnter (MsgOnHoverStart input)
        , onMouseLeave MsgOnHoverEnd
        ]
        [ button [ width fill, height fill ]
            { onPress = Just (MsgFocusInput input)
            , label =
                text
                    (round 2 input.pos
                        ++ (if EverySet.isEmpty input.hits then
                                " (empty)"

                            else
                                ""
                           )
                    )
            }
        , elWhen (model.hoveredInput == Just input) <|
            button [ alignRight, height fill ]
                { onPress = Just (MsgRemoveInput input)
                , label = text "❌"
                }
        ]


playerView : PlayerView -> Element Msg
playerView model =
    column [ width fill, spacing 20, navigation ]
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


progressBarView : PlayerView -> Element Msg
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


editorView : EditorView -> Element Msg
editorView model =
    column [ width fill, height fill, spaceEvenly ]
        [ el [] none
        , hitPropertiesView model.currentInput
        , hitEditorView model.currentInput
        , el [] none
        ]


hitPropertiesView : Maybe Input -> Element Msg
hitPropertiesView input =
    let
        kindTag kind =
            case kind of
                Regular ->
                    "regular"

                Long ->
                    "long"

                Pose ->
                    "pose"

        properties kind =
            if Maybe.map .kind input == Just kind then
                [ padding 20
                , Background.color <| rgb 0.5 0.5 0.5
                , Font.color <| rgb 0.1 0.1 0.1
                , Font.size 20
                , Font.center
                , checked True
                , tag (kindTag kind)
                ]

            else
                [ padding 20
                , Background.color <| rgb 0.2 0.2 0.2
                , Font.color <| rgb 0.9 0.9 0.9
                , Font.size 20
                , Font.center
                , checked False
                , tag (kindTag kind)
                ]
    in
    row [ width fill, padding 20, spaceEvenly ]
        [ row [ width fill, padding 20, spaceEvenly ]
            []
        , row [ width fill, padding 20, spaceEvenly ]
            [ button
                (properties Regular)
                { onPress = Just (MsgCurrentInputKind Regular)
                , label = text "Regular"
                }
            , button (properties Long)
                { onPress = Just (MsgCurrentInputKind Long)
                , label = text "Long"
                }
            , button (properties Pose)
                { onPress = Just (MsgCurrentInputKind Pose)
                , label = text "Pose"
                }
            ]
        , row [ width fill, padding 20, spaceEvenly ]
            []
        ]


hitEditorView : Maybe Input -> Element Msg
hitEditorView input =
    el [ width (fill |> maximum 400), height (fill |> maximum 400), centerX, mainContent ] <|
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


hitButton : Hit -> Maybe Input -> Element Msg
hitButton hit input =
    let
        hits =
            input |> Maybe.map .hits |> Maybe.withDefault EverySet.empty

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
    if EverySet.member hit hits then
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


propertiesView : SongView -> GameView -> Element Msg
propertiesView song game =
    column [ height fill, width (shrink |> minimum 200), centerX, spacing 60, aside ]
        [ songPropertiesView song
        , gamePropertiesView game
        ]


songPropertiesView : SongView -> Element Msg
songPropertiesView model =
    case model.song of
        None ->
            el [ centerX ] <|
                button [ centerX, padding 20, Background.color buttonColor, Border.rounded 5 ]
                    { onPress = Just MsgSelectSong
                    , label = text "o: Select Song"
                    }

        Loading _ ->
            el [ paddingXY 0 30, centerX ] <|
                text "Loading"

        Loaded song ->
            column [ centerX, spacing 10 ] <|
                [ el [ centerX ] <| text song.name
                , button [ centerX, padding 20, Background.color buttonColor, Border.rounded 5 ]
                    { onPress = Just MsgUnloadSong
                    , label = text "o: Unload Song"
                    }
                ]

        FailedToLoad ->
            none


gamePropertiesView : GameView -> Element Msg
gamePropertiesView model =
    case model.game of
        None ->
            column [ centerX, spacing 10 ] <|
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
            el [ centerX ] <|
                text "Loading"

        Loaded game ->
            column [ centerX, spacing 10 ] <|
                [ button [ centerX, padding 20, Background.color buttonColor, Border.rounded 5 ]
                    { onPress = Just MsgExportGame
                    , label = text "x: Export Game"
                    }
                , button [ centerX, padding 20, Background.color buttonColor, Border.rounded 5 ]
                    { onPress = Just MsgUnloadGame
                    , label = text "g: Unload Game"
                    }
                , stageSelectionView model game
                ]

        FailedToLoad ->
            column [ centerX, spacing 10 ] <|
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


stageSelectionView : GameView -> Game -> Element Msg
stageSelectionView model { stages } =
    column [ width fill ] <|
        List.map (stageSelectionRowView model) stages


stageSelectionRowView : GameView -> Stage -> Element Msg
stageSelectionRowView model stage =
    let
        level =
            case stage.level of
                Easy ->
                    "Easy"

                Normal ->
                    "Normal"

                Hard ->
                    "Hard"

                SuperHard ->
                    "SuperHard"

                AltEasy ->
                    "AltEasy"

                AltNormal ->
                    "AltNormal"

                AltHard ->
                    "AltHard"

                AltSuperHard ->
                    "AltSuperHard"

        player =
            case stage.player of
                P1 ->
                    "P1"

                P2 ->
                    "P2"

        isChecked =
            model.currentStage == Just stage
    in
    button
        [ width fill
        , padding 5
        , tag ("stage " ++ String.toLower level ++ " " ++ String.toLower player)
        , checked isChecked
        , attrWhen isChecked (Background.color buttonColor)
        ]
        { onPress = Just (MsgFocusStage stage)
        , label =
            row [ spacing 20, alignRight ]
                [ text level
                , text player
                , text (String.fromInt stage.maxScore)
                ]
        }


statusBar : StatusView -> Element Msg
statusBar model =
    row [ width fill ]
        [ text <|
            case model.mode of
                NormalMode ->
                    "Normal"

                PropertyMode ->
                    "Property"
        ]
