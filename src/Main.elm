module Main exposing (main)

import AMG
import Base64
import Browser
import Bytes exposing (Bytes)
import Data exposing (..)
import Element exposing (..)
import Element.Background as Background
import Element.Border as Border
import Element.Events exposing (onMouseEnter, onMouseLeave)
import Element.Font as Font
import Element.Input exposing (button, labelHidden, slider, thumb)
import Element.Lazy exposing (..)
import Element.Region exposing (aside, mainContent, navigation)
import Element.Utils exposing (attrWhen, checked, elWhen, id, tag)
import EverySet exposing (EverySet)
import File exposing (File)
import File.Download as Download
import File.Select as Select
import History exposing (History)
import Html exposing (Html)
import Html.Attributes exposing (style)
import Keyboard exposing (Mode(..))
import Pivot exposing (Pivot)
import Ports
import Task
import TimeArray as TA exposing (TimeArray)


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
    { mode : Mode
    , player : FileResource Player
    , editor : FileResource Editor
    }


type alias Player =
    { song : Song
    , isPlaying : Bool
    , pos : Float
    , duration : Float
    }


type alias Editor =
    { game : Game
    , history : History Game
    , hoveredInput : Maybe Input
    }


type Msg
    = MsgNoOp
    | MsgPlayer PlayerMsg
    | MsgEditor EditorMsg
    | MsgSong SongMsg
    | MsgGame GameMsg
    | MsgPos Float
    | MsgSetMode Mode
    | MsgCypressLoadSong String String
    | MsgCypressLoadGame String


type SongMsg
    = MsgSelectSong
    | MsgUnloadSong
    | MsgSongSelected File
    | MsgSongContent String
    | MsgSongLoaded (Result () Float)


type PlayerMsg
    = MsgBegin
    | MsgBackward
    | MsgPlayPause
    | MsgForward
    | MsgEnd
    | MsgSeek Float
    | MsgSeekBefore (Maybe Float)
    | MsgSeekAfter (Maybe Float)
    | MsgIsPlaying Bool


type GameMsg
    = MsgNewGame
    | MsgSelectGame
    | MsgUnloadGame
    | MsgExportGame
    | MsgGameSelected File
    | MsgGameLoaded Bytes


type EditorMsg
    = MsgToggleHit Hit
    | MsgSetInputKind Kind
    | MsgFocusInput Input
    | MsgRemoveInput Input
    | MsgRemoveCurrentInput
    | MsgPreviousInput
    | MsgNextInput
    | MsgUndo
    | MsgRedo
    | MsgOnInputHoverStart Input
    | MsgOnInputHoverEnd
    | MsgFocusStage Int
    | MsgApplyAllStages
    | MsgApplyOtherPlayer



-- Logic


init : Flags -> ( Model, Cmd Msg )
init _ =
    ( { mode = NormalMode
      , player = None
      , editor = None
      }
    , Cmd.none
    )


initPlayer : Song -> Player
initPlayer song =
    { song = song
    , isPlaying = False
    , pos = 0
    , duration = 0
    }


initEditor : Game -> Editor
initEditor game =
    { game = game
    , history = History.empty
    , hoveredInput = Nothing
    }


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        MsgNoOp ->
            ( model
            , Cmd.none
            )

        MsgSong subMsg ->
            updateResource updateSong subMsg .player (\player m -> { m | player = player }) model
                |> resetMode

        MsgPlayer subMsg ->
            updateInResource updatePlayer subMsg .player (\player m -> { m | player = player }) model
                |> resetMode

        MsgGame subMsg ->
            updateResource updateGame subMsg .editor (\editor m -> { m | editor = editor }) model
                |> resetMode

        MsgEditor subMsg ->
            updateInResource updateEditor subMsg .editor (\editor m -> { m | editor = editor }) model
                |> resetMode

        MsgSetMode mode ->
            ( { model | mode = mode }
            , Cmd.none
            )

        MsgCypressLoadSong name content ->
            ( { model | player = Loading (initPlayer { name = name }) }
            , Ports.load content
            )

        MsgCypressLoadGame content ->
            case Base64.toBytes content of
                Just bytes ->
                    update (MsgGame (MsgGameLoaded bytes)) model

                Nothing ->
                    ( model
                    , Cmd.none
                    )

        MsgPos pos ->
            case model.player of
                Loaded player ->
                    let
                        newPlayer =
                            Loaded { player | pos = pos }

                        ( newEditor, cmds ) =
                            case model.editor of
                                Loaded editor ->
                                    let
                                        newGame =
                                            mapInputs (TA.updatePos (secToFrame pos)) editor.game
                                    in
                                    ( Loaded { editor | game = newGame }
                                    , case ( player.isPlaying, TA.getCurrent (getInputs { editor | game = newGame }) ) of
                                        ( True, Just input ) ->
                                            Ports.scrollIntoView ("input" ++ String.fromInt input.pos)

                                        _ ->
                                            Cmd.none
                                    )

                                _ ->
                                    ( model.editor
                                    , Cmd.none
                                    )
                    in
                    ( { model | player = newPlayer, editor = newEditor }
                    , cmds
                    )

                _ ->
                    ( model
                    , Cmd.none
                    )


updateSong : SongMsg -> FileResource Player -> ( FileResource Player, Cmd Msg )
updateSong msg model =
    case msg of
        MsgSelectSong ->
            ( model
            , Select.file [] (MsgSong << MsgSongSelected)
            )

        MsgUnloadSong ->
            ( None
            , Ports.unload
            )

        MsgSongSelected file ->
            ( Loading (initPlayer { name = File.name file })
            , Task.perform (MsgSong << MsgSongContent) (File.toUrl file)
            )

        MsgSongContent songBase64 ->
            ( model
            , Ports.load songBase64
            )

        MsgSongLoaded result ->
            ( case ( result, model ) of
                ( Ok duration, Loading song ) ->
                    Loaded { song | duration = duration, song = song.song }

                _ ->
                    FailedToLoad
            , Cmd.none
            )


updatePlayer : PlayerMsg -> Player -> ( Player, Cmd Msg )
updatePlayer msg model =
    case msg of
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

        MsgSeekBefore pos ->
            ( model
            , Ports.seek (Maybe.withDefault 0 pos)
            )

        MsgSeekAfter pos ->
            ( model
            , Ports.seek (Maybe.withDefault model.duration pos)
            )

        MsgIsPlaying isPlaying ->
            ( { model | isPlaying = isPlaying }
            , Cmd.none
            )


updateGame : GameMsg -> FileResource Editor -> ( FileResource Editor, Cmd Msg )
updateGame msg model =
    case msg of
        MsgNewGame ->
            ( Loaded (initEditor emptyGame)
            , Cmd.none
            )

        MsgSelectGame ->
            ( model
            , Select.file [] (MsgGame << MsgGameSelected)
            )

        MsgUnloadGame ->
            ( None
            , Cmd.none
            )

        MsgExportGame ->
            case model of
                Loaded editor ->
                    ( model
                    , Download.bytes "song.AMG" "application/octet-stream" (AMG.encode editor.game)
                    )

                _ ->
                    ( model
                    , Cmd.none
                    )

        MsgGameSelected file ->
            ( model
            , Task.perform (MsgGame << MsgGameLoaded) (File.toBytes file)
            )

        MsgGameLoaded bytes ->
            case AMG.decode bytes of
                Just game ->
                    ( Loaded (initEditor game)
                    , Cmd.none
                    )

                Nothing ->
                    ( FailedToLoad
                    , Cmd.none
                    )


updateEditor : EditorMsg -> Editor -> ( Editor, Cmd Msg )
updateEditor msg model =
    case msg of
        MsgToggleHit hit ->
            ( model |> withHistory ((mapCurrentInput << mapHit) (toggleMember hit))
            , Cmd.none
            )

        MsgSetInputKind kind ->
            ( model |> withHistory (mapCurrentInput (setKind kind))
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

        MsgFocusInput input ->
            ( model
            , Ports.seek (frameToSec input.pos)
            )

        MsgPreviousInput ->
            ( model
            , send ((MsgPlayer << MsgSeekBefore) (TA.getPrevious (getInputs model) |> Maybe.map .pos |> Maybe.map frameToSec))
            )

        MsgNextInput ->
            ( model
            , send ((MsgPlayer << MsgSeekAfter) (TA.getNext (getInputs model) |> Maybe.map .pos |> Maybe.map frameToSec))
            )

        MsgUndo ->
            model |> applyMoveInHistory (History.undo model.history)

        MsgRedo ->
            model |> applyMoveInHistory (History.redo model.history)

        MsgOnInputHoverStart input ->
            ( { model | hoveredInput = Just input }
            , Cmd.none
            )

        MsgOnInputHoverEnd ->
            ( { model | hoveredInput = Nothing }
            , Cmd.none
            )

        MsgFocusStage pos ->
            ( { model | game = mapStages (Pivot.withRollback (Pivot.goTo pos)) model.game }
            , Cmd.none
            )

        MsgApplyAllStages ->
            ( { model | game = mapStages applyAllStages model.game }
            , Cmd.none
            )

        MsgApplyOtherPlayer ->
            ( { model | game = mapStages applyOtherPlayer model.game }
            , Cmd.none
            )


subscriptions : Model -> Sub Msg
subscriptions model =
    let
        openSong =
            case model.player of
                None ->
                    MsgSong MsgSelectSong

                FailedToLoad ->
                    MsgSong MsgSelectSong

                _ ->
                    MsgSong MsgUnloadSong

        openGame =
            case model.editor of
                None ->
                    MsgGame MsgSelectGame

                FailedToLoad ->
                    MsgGame MsgSelectGame

                _ ->
                    MsgGame MsgUnloadGame
    in
    Sub.batch
        [ Ports.subscriptions
            { invalidCommand = MsgNoOp
            , isPlaying = MsgPlayer << MsgIsPlaying
            , pos = MsgPos
            , songLoaded = MsgSong << MsgSongLoaded
            }
        , Keyboard.subscriptions model.mode
            { applyOtherPlayer = MsgEditor MsgApplyOtherPlayer
            , applyAllStages = MsgEditor MsgApplyAllStages
            , backward = MsgPlayer MsgBackward
            , deleteCurrentInput = MsgEditor MsgRemoveCurrentInput
            , exportGame = MsgGame MsgExportGame
            , forward = MsgPlayer MsgForward
            , mode = MsgSetMode
            , newGame = MsgGame MsgNewGame
            , nextInput = MsgEditor MsgNextInput
            , openGame = openGame
            , openSong = openSong
            , playPause = MsgPlayer MsgPlayPause
            , previousInput = MsgEditor MsgPreviousInput
            , redo = MsgEditor MsgRedo
            , setKind = MsgEditor << MsgSetInputKind
            , toggleHit = MsgEditor << MsgToggleHit
            , undo = MsgEditor MsgUndo
            }
        , Ports.cypressSubscriptions
            { invalidCommand = MsgNoOp
            , loadGame = MsgCypressLoadGame
            , loadSong = MsgCypressLoadSong
            }
        ]



-- Update utils


updateResource :
    (msg -> FileResource model -> ( FileResource model, Cmd Msg ))
    -> msg
    -> (Model -> FileResource model)
    -> (FileResource model -> Model -> Model)
    -> Model
    -> ( Model, Cmd Msg )
updateResource f msg get set model =
    let
        ( newSubModel, cmds ) =
            f msg (get model)
    in
    ( model |> set newSubModel
    , cmds
    )


updateInResource :
    (msg -> model -> ( model, Cmd Msg ))
    -> msg
    -> (Model -> FileResource model)
    -> (FileResource model -> Model -> Model)
    -> Model
    -> ( Model, Cmd Msg )
updateInResource f msg get set model =
    case get model of
        Loaded subModel ->
            let
                ( newSubModel, cmds ) =
                    f msg subModel
            in
            ( model |> set (Loaded newSubModel)
            , cmds
            )

        _ ->
            ( model
            , Cmd.none
            )


send : Msg -> Cmd Msg
send msg =
    Task.perform identity (Task.succeed msg)



-- Keyboard


resetMode : ( Model, Cmd Msg ) -> ( Model, Cmd Msg )
resetMode ( model, cmds ) =
    ( { model | mode = NormalMode }
    , cmds
    )



-- Time


frameToSec : Int -> Float
frameToSec frame =
    toFloat frame / 60


secToFrame : Float -> Int
secToFrame sec =
    ceiling (sec * 60)



-- Game


getInputs : Editor -> TimeArray Input
getInputs model =
    Pivot.getC model.game.stages |> .inputs


pivotRemoveElement : Stage -> Pivot Stage -> Pivot Stage
pivotRemoveElement stage =
    Pivot.withRollback <|
        Pivot.toList
            >> List.filter ((/=) stage)
            >> Pivot.fromList


pivotRemoveCurrentElement : Pivot Stage -> Pivot Stage
pivotRemoveCurrentElement stages =
    let
        stage =
            Pivot.getC stages
    in
    pivotRemoveElement stage stages


applyAllStages : Pivot Stage -> Pivot Stage
applyAllStages stages =
    let
        stage =
            Pivot.getC stages

        allStages _ =
            [ ( Easy, P1 )
            , ( Easy, P2 )
            , ( Normal, P1 )
            , ( Normal, P2 )
            , ( Hard, P1 )
            , ( Hard, P2 )
            , ( SuperHard, P1 )
            , ( SuperHard, P2 )
            ]
                |> List.map (\( l, p ) -> { stage | level = l, player = p })
                |> Pivot.fromList
    in
    Pivot.withRollback
        allStages
        stages


applyOtherPlayer : Pivot Stage -> Pivot Stage
applyOtherPlayer stages =
    let
        stage =
            Pivot.getC stages
    in
    Pivot.mapA
        (\s ->
            if s.level == stage.level then
                { stage | player = s.player }

            else
                s
        )
        stages



-- Editor


mapStages : (Pivot Stage -> Pivot Stage) -> Game -> Game
mapStages f game =
    { game | stages = f game.stages }


mapStage : (Stage -> Stage) -> Game -> Game
mapStage f game =
    { game | stages = Pivot.mapC f game.stages }


mapInputs : (TimeArray Input -> TimeArray Input) -> Game -> Game
mapInputs f =
    mapStage (\stage -> { stage | inputs = f stage.inputs })


mapCurrentInput : (Input -> Input) -> Game -> Game
mapCurrentInput f =
    mapInputs (TA.mapCurrent emptyInput f)


removeInput : Input -> Game -> Game
removeInput i =
    mapInputs (TA.remove i)


removeCurrentInput : Game -> Game
removeCurrentInput =
    mapInputs TA.removeCurrent


mapHit : (EverySet Hit -> EverySet Hit) -> Input -> Input
mapHit f input =
    { input | hits = f input.hits }


toggleMember : elem -> EverySet elem -> EverySet elem
toggleMember elem set =
    if EverySet.member elem set then
        EverySet.remove elem set

    else
        EverySet.insert elem set


setKind : Kind -> Input -> Input
setKind kind input =
    { input
        | kind = kind
        , duration =
            case kind of
                Long ->
                    60

                _ ->
                    0
    }



-- History


withHistory : (Game -> Game) -> Editor -> Editor
withHistory f model =
    let
        g =
            f model.game
    in
    { model | game = g, history = History.record g model.history }


applyMoveInHistory : ( History Game, Maybe Game ) -> Editor -> ( Editor, Cmd Msg )
applyMoveInHistory ( history, maybeGame ) model =
    let
        game =
            maybeGame |> Maybe.withDefault emptyGame

        newModel =
            { model | game = game, history = history }
    in
    ( newModel
    , Ports.seek (frameToSec (TA.getPos (getInputs newModel)))
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
    { inputs : List Input
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
    }


type alias StatusView =
    { mode : Mode
    }


view : Model -> Html Msg
view model =
    let
        song =
            mapResource .song model.player

        game =
            mapResource .game model.editor

        player =
            case model.player of
                Loaded p ->
                    { isPlaying = p.isPlaying
                    , pos = p.pos
                    , duration = p.duration
                    }

                _ ->
                    { isPlaying = False
                    , pos = 0
                    , duration = 0
                    }

        editor =
            case model.editor of
                Loaded e ->
                    e

                _ ->
                    initEditor emptyGame

        inputs =
            getInputs editor
    in
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
                { inputs = TA.toList inputs
                , hoveredInput = editor.hoveredInput
                , currentInput = TA.getCurrent inputs
                }
            , player = player
            , editor =
                { currentInput = TA.getCurrent inputs
                }
            , song =
                { song = song
                }
            , game =
                { game = game
                }
            , status =
                { mode = model.mode
                }
            }
        )


mainView : ModelView -> Element Msg
mainView model =
    -- using clip and flex-shrink to work around scrollbar bug
    -- see https://github.com/mdgriffith/elm-ui/issues/12.
    column [ width fill, height fill, padding 20, spacing 20, clip ]
        [ row [ width fill, height fill, spacing 40, clip, htmlAttribute (style "flex-shrink" "1") ]
            [ lazy inputListView model.inputs
            , column [ width fill, height fill, spacing 5 ]
                [ lazy playerView model.player
                , lazy editorView model.editor
                ]
            , lazy2 propertiesView model.song model.game
            ]
        , lazy statusBar model.status
        ]


inputListView : InputView -> Element Msg
inputListView model =
    column [ height fill, width (shrink |> minimum 200), scrollbars, aside, spacing 5 ] <|
        List.indexedMap (inputRowView model) model.inputs


inputRowView : InputView -> Int -> Input -> Element Msg
inputRowView model pos input =
    let
        isChecked =
            model.currentInput == Just input
    in
    row
        [ width fill
        , padding 5
        , id ("input" ++ String.fromInt input.pos)
        , tag ("hit " ++ String.fromInt (pos + 1))
        , checked isChecked
        , attrWhen isChecked (Background.color buttonColor)
        , onMouseEnter (MsgEditor (MsgOnInputHoverStart input))
        , onMouseLeave (MsgEditor MsgOnInputHoverEnd)
        ]
        [ button [ width fill, height fill ]
            { onPress = Just (MsgEditor (MsgFocusInput input))
            , label =
                text
                    (String.fromInt input.pos
                        ++ (if EverySet.isEmpty input.hits then
                                " (empty)"

                            else
                                ""
                           )
                    )
            }
        , elWhen (model.hoveredInput == Just input) <|
            button [ alignRight, height fill ]
                { onPress = Just (MsgEditor (MsgRemoveInput input))
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
        { onPress = Just (MsgPlayer MsgBegin)
        , label = text "⏮"
        }


backwardBtn : Element Msg
backwardBtn =
    button []
        { onPress = Just (MsgPlayer MsgBackward)
        , label = text "⏪"
        }


playPauseBtn : Bool -> Element Msg
playPauseBtn isPlaying =
    button []
        { onPress = Just (MsgPlayer MsgPlayPause)
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
        { onPress = Just (MsgPlayer MsgForward)
        , label = text "⏩"
        }


endBtn : Element Msg
endBtn =
    button []
        { onPress = Just (MsgPlayer MsgEnd)
        , label = text "⏭"
        }


progressBarView : PlayerView -> Element Msg
progressBarView model =
    el [ width fill ] <|
        slider [ Background.color buttonColor, Border.rounded 8 ]
            { onChange = MsgPlayer << MsgSeek
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
                { onPress = Just (MsgEditor (MsgSetInputKind Regular))
                , label = text "Regular"
                }
            , button (properties Long)
                { onPress = Just (MsgEditor (MsgSetInputKind Long))
                , label = text "Long"
                }
            , button (properties Pose)
                { onPress = Just (MsgEditor (MsgSetInputKind Pose))
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
            { onPress = Just (MsgEditor (MsgToggleHit hit))
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
            { onPress = Just (MsgEditor (MsgToggleHit hit))
            , label = text key
            }


propertiesView : SongView -> GameView -> Element Msg
propertiesView song game =
    column [ height fill, width (shrink |> minimum 200), centerX, spacing 30, aside ]
        [ songPropertiesView song
        , gamePropertiesView game
        ]


songPropertiesView : SongView -> Element Msg
songPropertiesView model =
    case model.song of
        None ->
            el [ centerX ] <|
                button [ centerX, padding 20, Background.color buttonColor, Border.rounded 5 ]
                    { onPress = Just (MsgSong MsgSelectSong)
                    , label = text "o: Select Song"
                    }

        Loading _ ->
            el [ paddingXY 0 30, centerX ] <|
                text "Loading"

        Loaded song ->
            column [ centerX, spacing 10 ] <|
                [ el [ centerX ] <| text song.name
                , button [ centerX, padding 20, Background.color buttonColor, Border.rounded 5 ]
                    { onPress = Just (MsgSong MsgUnloadSong)
                    , label = text "o: Unload Song"
                    }
                ]

        FailedToLoad ->
            column [ centerX, spacing 10 ] <|
                [ el [ centerX ] <|
                    button [ centerX, padding 20, Background.color buttonColor, Border.rounded 5 ]
                        { onPress = Just (MsgSong MsgSelectSong)
                        , label = text "o: Select Song"
                        }
                , el [ centerX ] <|
                    text "Failed to load"
                ]


gamePropertiesView : GameView -> Element Msg
gamePropertiesView model =
    case model.game of
        None ->
            column [ centerX, spacing 10 ] <|
                [ button [ centerX, padding 20, Background.color buttonColor, Border.rounded 5 ]
                    { onPress = Just (MsgGame MsgSelectGame)
                    , label = text "g: Select Game file"
                    }
                , button [ centerX, padding 20, Background.color buttonColor, Border.rounded 5 ]
                    { onPress = Just (MsgGame MsgNewGame)
                    , label = text "n: New Game file"
                    }
                ]

        Loading _ ->
            el [ centerX ] <|
                text "Loading"

        Loaded game ->
            column [ centerX, spacing 10 ] <|
                [ button [ centerX, padding 20, Background.color buttonColor, Border.rounded 5 ]
                    { onPress = Just (MsgGame MsgExportGame)
                    , label = text "e: Export Game"
                    }
                , button [ centerX, padding 20, Background.color buttonColor, Border.rounded 5 ]
                    { onPress = Just (MsgGame MsgUnloadGame)
                    , label = text "g: Unload Game"
                    }
                , button [ centerX, padding 20, Background.color buttonColor, Border.rounded 5 ]
                    { onPress = Just (MsgEditor MsgApplyAllStages)
                    , label = text "s: Apply all Stages"
                    }
                , button [ centerX, padding 20, Background.color buttonColor, Border.rounded 5 ]
                    { onPress = Just (MsgEditor MsgApplyOtherPlayer)
                    , label = text "p: Apply other Player"
                    }
                , stageSelectionView model game
                ]

        FailedToLoad ->
            column [ centerX, spacing 10 ] <|
                [ button [ centerX, padding 20, Background.color buttonColor, Border.rounded 5 ]
                    { onPress = Just (MsgGame MsgSelectGame)
                    , label = text "g: Select Game file"
                    }
                , button [ centerX, padding 20, Background.color buttonColor, Border.rounded 5 ]
                    { onPress = Just (MsgGame MsgNewGame)
                    , label = text "n: New Game file"
                    }
                , el [ centerX ] <|
                    text "Failed to load"
                ]


stageSelectionView : GameView -> Game -> Element Msg
stageSelectionView model { stages } =
    column [ width fill ] <|
        List.map (stageSelectionRowView model stages) (Pivot.toList (Pivot.indexAbsolute stages))


stageSelectionRowView : GameView -> Pivot Stage -> ( Int, Stage ) -> Element Msg
stageSelectionRowView model stages ( pos, stage ) =
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

        player =
            case stage.player of
                P1 ->
                    "P1"

                P2 ->
                    "P2"

        isChecked =
            Pivot.getC stages == stage
    in
    row
        [ width fill
        , padding 5
        , tag ("stage " ++ String.toLower level ++ " " ++ String.toLower player)
        , checked isChecked
        , attrWhen isChecked (Background.color buttonColor)
        ]
        [ button [ width fill ]
            { onPress = Just (MsgEditor (MsgFocusStage pos))
            , label =
                row [ spacing 20, alignRight ]
                    [ text level
                    , text player
                    , text (String.fromInt stage.maxScore)
                    ]
            }
        ]


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
