module ReferenceInputs exposing (Inputs, fromList, mapCurrentInput, updatePos)

import Data exposing (Hit(..), Input, Kind(..))
import EverySet exposing (EverySet)


type Inputs
    = I
        { inputs : List Input
        , currentInput : Maybe Input
        , pos : Int
        }


fromList : List Input -> Inputs
fromList list =
    I { inputs = list, currentInput = Nothing, pos = 0 }


updatePos : Int -> Inputs -> Inputs
updatePos pos (I model) =
    I { model | currentInput = findCurrentInput pos model.inputs, pos = pos }


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


findCurrentInput : Int -> List Input -> Maybe Input
findCurrentInput pos inputs =
    inputs
        |> List.filter (\input -> pos >= input.pos - input.offset && pos <= input.pos + input.offset)
        |> List.head


emptyInput : Int -> Input
emptyInput pos =
    { hits = EverySet.empty
    , pos = pos
    , offset = 3
    , kind = Regular
    }
