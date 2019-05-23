module Inputs exposing (Inputs, empty, fromList, getCurrentInput, getInputs, getNextInputPos, getPos, getPreviousInputPos, mapCurrentInput, mapCurrentInputHits, removeCurrentInput, removeInput, toggleMember, updatePos)

import Data exposing (Hit(..), Input, Kind(..))
import EverySet exposing (EverySet)


type Inputs
    = I
        { inputs : List Input
        , currentInput : Maybe Input
        , pos : Int
        }


empty : Inputs
empty =
    I { inputs = [], currentInput = Nothing, pos = 0 }


fromList : List Input -> Inputs
fromList list =
    I { inputs = list, currentInput = Nothing, pos = 0 }


getInputs : Inputs -> List Input
getInputs (I model) =
    model.inputs


getCurrentInput : Inputs -> Maybe Input
getCurrentInput (I model) =
    model.currentInput


updatePos : Int -> Inputs -> Inputs
updatePos pos (I model) =
    I { model | currentInput = findCurrentInput pos model.inputs, pos = pos }


toggleMember : elem -> EverySet elem -> EverySet elem
toggleMember elem set =
    if EverySet.member elem set then
        EverySet.remove elem set

    else
        EverySet.insert elem set


mapCurrentInput : (Input -> Input) -> Inputs -> Inputs
mapCurrentInput function (I model) =
    let
        currentInput =
            model.currentInput
                |> Maybe.withDefault (emptyInput model.pos)
                |> function

        updatedInputs =
            case model.currentInput of
                Just input ->
                    model.inputs
                        |> List.map
                            (\i ->
                                if i == input then
                                    currentInput

                                else
                                    i
                            )

                Nothing ->
                    currentInput :: model.inputs
    in
    I { model | inputs = List.sortBy .pos updatedInputs, currentInput = Just currentInput }


mapCurrentInputHits : (EverySet Hit -> EverySet Hit) -> Inputs -> Inputs
mapCurrentInputHits function =
    mapCurrentInput (mapInputHits function)


removeInput : Input -> Inputs -> Inputs
removeInput input (I model) =
    I
        { model
            | inputs = List.filter ((/=) input) model.inputs
            , currentInput =
                if model.currentInput == Just input then
                    Nothing

                else
                    model.currentInput
        }


removeCurrentInput : Inputs -> Inputs
removeCurrentInput ((I model) as inputs) =
    case model.currentInput of
        Just input ->
            removeInput input inputs

        _ ->
            inputs


getPos : Inputs -> Int
getPos (I model) =
    model.pos


getPreviousInputPos : Inputs -> Maybe Int
getPreviousInputPos (I model) =
    model.inputs
        |> List.filter (\i -> i.pos - i.offset < model.pos && Just i /= model.currentInput)
        |> List.reverse
        |> List.head
        |> Maybe.map .pos


getNextInputPos : Inputs -> Maybe Int
getNextInputPos (I model) =
    model.inputs
        |> List.filter (\i -> i.pos - i.offset > model.pos && Just i /= model.currentInput)
        |> List.head
        |> Maybe.map .pos


mapInputHits : (EverySet Hit -> EverySet Hit) -> Input -> Input
mapInputHits function input =
    { input | hits = function input.hits }


findCurrentInput : Int -> List Input -> Maybe Input
findCurrentInput pos inputs =
    inputs
        |> List.filter (\input -> pos - input.offset >= input.pos - input.offset && pos <= input.pos + input.offset)
        |> List.head


emptyInput : Int -> Input
emptyInput pos =
    { hits = EverySet.empty
    , pos = pos
    , offset = 3
    , kind = Regular
    }
