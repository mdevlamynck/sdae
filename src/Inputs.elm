module Inputs exposing (Index(..), Inputs, empty, fromList, getCurrentInput, getInputs, getNextInputPos, getPos, getPreviousInputPos, mapCurrentInput, mapCurrentInputHits, removeCurrentInput, removeInput, toggleMember, updatePos)

import Array exposing (Array)
import Array.Extra as Array
import Data exposing (Hit(..), Input, Kind(..))
import EverySet exposing (EverySet)


type Inputs
    = I
        { inputs : Array Input
        , currentIndex : Index
        , currentInput : Maybe Input
        , pos : Int
        }


type Index
    = At Int
    | Before Int


empty : Inputs
empty =
    I
        { inputs = Array.empty
        , currentIndex = Before 0
        , currentInput = Nothing
        , pos = 0
        }


fromList : List Input -> Inputs
fromList list =
    I
        { inputs = Array.fromList list
        , currentIndex = Before 0
        , currentInput = Nothing
        , pos = 0
        }


getInputs : Inputs -> List Input
getInputs (I model) =
    Array.toList model.inputs


getCurrentInput : Inputs -> Maybe Input
getCurrentInput (I model) =
    model.currentInput


getPos : Inputs -> Int
getPos (I model) =
    model.pos


toggleMember : elem -> EverySet elem -> EverySet elem
toggleMember elem set =
    if EverySet.member elem set then
        EverySet.remove elem set

    else
        EverySet.insert elem set


getPreviousInputPos : Inputs -> Maybe Int
getPreviousInputPos ((I model) as inputs) =
    let
        before i =
            i.pos - i.offset < model.pos && Just i /= getCurrentInput inputs
    in
    model.inputs
        |> Array.filter before
        |> last
        |> Maybe.map .pos


getNextInputPos : Inputs -> Maybe Int
getNextInputPos ((I model) as inputs) =
    let
        after i =
            i.pos - i.offset > model.pos && Just i /= getCurrentInput inputs
    in
    model.inputs
        |> Array.filter after
        |> first
        |> Maybe.map .pos


updatePos : Int -> Inputs -> Inputs
updatePos pos ((I model) as inputs) =
    let
        ( index, input ) =
            findCurrentInput pos inputs
    in
    I
        { model
            | currentInput = input
            , currentIndex = index
            , pos = pos
        }


mapCurrentInput : (Input -> Input) -> Inputs -> Inputs
mapCurrentInput function (I model) =
    let
        currentInput =
            model.currentInput
                |> Maybe.withDefault (emptyInput model.pos)
                |> function

        updatedInputs =
            case model.currentIndex of
                At index ->
                    Array.set index currentInput model.inputs

                Before index ->
                    insertAt index currentInput model.inputs
    in
    I { model | inputs = updatedInputs, currentInput = Just currentInput }


mapCurrentInputHits : (EverySet Hit -> EverySet Hit) -> Inputs -> Inputs
mapCurrentInputHits function =
    mapCurrentInput (mapInputHits function)


removeInput : Input -> Inputs -> Inputs
removeInput input ((I model) as inputs) =
    I
        { model
            | inputs = Array.filter ((/=) input) model.inputs
            , currentInput =
                if getCurrentInput inputs == Just input then
                    Nothing

                else
                    model.currentInput
        }


removeCurrentInput : Inputs -> Inputs
removeCurrentInput ((I model) as inputs) =
    case getCurrentInput inputs of
        Just input ->
            removeInput input inputs

        _ ->
            inputs


mapInputHits : (EverySet Hit -> EverySet Hit) -> Input -> Input
mapInputHits function input =
    { input | hits = function input.hits }


findCurrentInput : Int -> Inputs -> ( Index, Maybe Input )
findCurrentInput pos (I model) =
    let
        cmp input =
            if pos < input.pos - input.offset then
                LT

            else if pos >= input.pos + input.offset + input.duration then
                GT

            else
                EQ

        index =
            case model.currentIndex of
                At i ->
                    i

                Before i ->
                    i - 1

        currentInput =
            Array.get index model.inputs

        nextInput =
            Array.get (index + 1) model.inputs
    in
    case ( Maybe.map cmp currentInput, Maybe.map cmp nextInput ) of
        ( Just EQ, _ ) ->
            ( At index, currentInput )

        ( Just GT, Just LT ) ->
            ( Before index, Nothing )

        ( _, Just EQ ) ->
            ( At (index + 1), nextInput )

        _ ->
            search cmp 0 (Array.length model.inputs) model.inputs


emptyInput : Int -> Input
emptyInput pos =
    { hits = EverySet.empty
    , pos = pos
    , offset = 3
    , duration = 0
    , kind = Regular
    }


first : Array a -> Maybe a
first a =
    Array.get 0 a


last : Array a -> Maybe a
last a =
    Array.get (Array.length a - 1) a


insertAt : Int -> a -> Array a -> Array a
insertAt pos a array =
    let
        ( before, after ) =
            Array.splitAt pos array
    in
    Array.append (Array.push a before) after


search : (a -> Order) -> Int -> Int -> Array a -> ( Index, Maybe a )
search f low high a =
    let
        middle =
            ((high - low) // 2) + low
    in
    case Array.get middle a of
        Just e ->
            case f e of
                EQ ->
                    ( At middle, Just e )

                LT ->
                    if middle == low then
                        ( Before middle, Nothing )

                    else
                        search f low middle a

                GT ->
                    if middle == low then
                        ( Before (middle + 1), Nothing )

                    else
                        search f middle high a

        Nothing ->
            ( Before 0, Nothing )
