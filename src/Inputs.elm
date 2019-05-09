module Inputs exposing (Hit(..), Input, Inputs, empty, getCurrentInput, getInputs, getNextInputPos, getPreviousInputPos, mapCurrentInputHits, removeInput, toggleMember, updatePos)

import EverySet exposing (EverySet)


type Inputs
    = Inputs { inputs : List Input, currentInput : Maybe Input, pos : Float }


type alias Input =
    { hits : EverySet Hit
    , pos : Float
    , duration : Float
    }


type Hit
    = LeftUp
    | LeftMiddle
    | LeftDown
    | RightUp
    | RightMiddle
    | RightDown


empty : Inputs
empty =
    Inputs { inputs = [], currentInput = Nothing, pos = 0 }


getInputs : Inputs -> List Input
getInputs (Inputs inputs) =
    inputs.inputs


getCurrentInput : Inputs -> Input
getCurrentInput (Inputs inputs) =
    inputs.currentInput
        |> Maybe.withDefault (emptyInput inputs.pos)


updatePos : Float -> Inputs -> Inputs
updatePos pos (Inputs inputs) =
    Inputs { inputs | currentInput = findCurrentInput pos inputs.inputs, pos = pos }


toggleMember : elem -> EverySet elem -> EverySet elem
toggleMember elem set =
    if EverySet.member elem set then
        EverySet.remove elem set

    else
        EverySet.insert elem set


mapCurrentInputHits : (EverySet Hit -> EverySet Hit) -> Inputs -> Inputs
mapCurrentInputHits function (Inputs inputs) =
    let
        currentInput =
            inputs.currentInput
                |> Maybe.withDefault (emptyInput inputs.pos)
                |> mapInputHits function

        updatedInputs =
            case inputs.currentInput of
                Just input ->
                    inputs.inputs
                        |> List.map
                            (\i ->
                                if i == input then
                                    currentInput

                                else
                                    i
                            )

                Nothing ->
                    currentInput :: inputs.inputs
    in
    Inputs { inputs | inputs = List.sortBy .pos updatedInputs, currentInput = Just currentInput }


removeInput : Input -> Inputs -> Inputs
removeInput input (Inputs inputs) =
    Inputs
        { inputs
            | inputs = List.filter ((/=) input) inputs.inputs
            , currentInput =
                if inputs.currentInput == Just input then
                    Nothing

                else
                    inputs.currentInput
        }


getPreviousInputPos : Inputs -> Maybe Float
getPreviousInputPos (Inputs inputs) =
    inputs.inputs
        |> List.filter (\i -> i.pos < inputs.pos && Just i /= inputs.currentInput)
        |> List.reverse
        |> List.head
        |> Maybe.map .pos


getNextInputPos : Inputs -> Maybe Float
getNextInputPos (Inputs inputs) =
    inputs.inputs
        |> List.filter (\i -> i.pos > inputs.pos && Just i /= inputs.currentInput)
        |> List.head
        |> Maybe.map .pos


mapInputHits : (EverySet Hit -> EverySet Hit) -> Input -> Input
mapInputHits function input =
    { input | hits = function input.hits }


findCurrentInput : Float -> List Input -> Maybe Input
findCurrentInput pos inputs =
    inputs
        |> List.filter (\input -> pos >= input.pos && pos <= input.pos + input.duration)
        |> List.head


emptyInput : Float -> Input
emptyInput pos =
    { hits = EverySet.empty
    , pos = pos
    , duration = 0.1
    }
