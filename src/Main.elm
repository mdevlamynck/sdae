module Main exposing (main)

import Browser
import Element exposing (..)
import Element.Background as Background
import Element.Events exposing (..)
import Element.Font as Font
import Element.Input exposing (button)
import File exposing (File)
import File.Select as Select
import Html exposing (Html, progress)
import Html.Attributes exposing (attribute)
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



-- Data


type alias Flags =
    {}


type alias Model =
    { -- Player
      isPlaying : Bool
    , pos : Float
    , length : Float

    -- Song
    , song : Maybe Song

    -- Game File
    , game : Maybe Game

    -- Inputs
    , inputs : List Input
    }


type alias Song =
    { file : File
    }


type alias Game =
    {}


type alias Input =
    {}


type
    Msg
    -- Player
    = MsgPlayPause
      -- Song
    | MsgSelectSong
    | MsgSongSelected File
    | MsgSongLoaded String



-- Logic


init : Flags -> ( Model, Cmd Msg )
init _ =
    ( { inputs = [ {}, {} ]
      , isPlaying = False
      , pos = 50
      , length = 100
      , song = Nothing
      , game = Nothing
      }
    , Cmd.none
    )


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        MsgPlayPause ->
            ( { model | isPlaying = not model.isPlaying }
            , Ports.playPause (not model.isPlaying)
            )

        MsgSelectSong ->
            ( model
            , Select.file [ "audio/basic" ] MsgSongSelected
            )

        MsgSongSelected file ->
            ( { model | song = Just { file = file } }
            , Task.perform MsgSongLoaded (File.toUrl file)
            )

        MsgSongLoaded songBase64 ->
            ( model
            , Ports.load songBase64
            )


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.none



-- View


view : Model -> Html Msg
view model =
    layout
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
    column [ height fill, width (shrink |> minimum 300), centerX ] <|
        List.map inputRowView model.inputs


inputRowView : Input -> Element Msg
inputRowView model =
    text "input row"


playerView : Model -> Element Msg
playerView model =
    column [ width fill, spacing 5 ]
        [ row [ centerX, spacing 5, Font.size 30 ]
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
    el [] <|
        text "⏮"


backwardBtn : Element Msg
backwardBtn =
    el [] <|
        text "⏪"


playPauseBtn : Bool -> Element Msg
playPauseBtn isPlaying =
    el [ onClick MsgPlayPause ] <|
        text <|
            if isPlaying then
                "⏸"

            else
                "⏯"


forwardBtn : Element Msg
forwardBtn =
    el [] <|
        text "⏩"


endBtn : Element Msg
endBtn =
    el [] <|
        text "⏭"


progressBarView : Model -> Element Msg
progressBarView model =
    el [ width fill ] <|
        html <|
            progress
                [ attribute "value" (String.fromFloat model.pos)
                , attribute "max" (String.fromFloat model.length)
                ]
                []


editorView : Model -> Element Msg
editorView model =
    el [ width fill, height fill ] <|
        text "editor view"


propertiesView : Model -> Element Msg
propertiesView model =
    column [ height fill, width (shrink |> minimum 300), centerX, spacing 5 ]
        [ case model.song of
            Nothing ->
                openSongView

            Just song ->
                songPropertiesView song
        , case model.game of
            Nothing ->
                openGameView

            Just game ->
                gamePropertiesView game
        ]


openSongView : Element Msg
openSongView =
    button []
        { onPress = Just MsgSelectSong
        , label = text "Select Song"
        }


openGameView : Element Msg
openGameView =
    none


songPropertiesView : Song -> Element Msg
songPropertiesView song =
    none


gamePropertiesView : Game -> Element Msg
gamePropertiesView game =
    none
