module TimeArray exposing (TimeArray, empty, fromList, getCurrent, getNext, getPos, getPrevious, mapCurrent, remove, removeCurrent, toList, updatePos)

import Array exposing (Array)
import Array.Extra as Array


type TimeArray i
    = TA
        { array : Array i
        , index : Index
        , current : Maybe i
        , pos : Int
        , compare : Int -> i -> Order
        }


type Index
    = At Int
    | Before Int


empty : (Int -> i -> Order) -> TimeArray i
empty compare =
    TA
        { array = Array.empty
        , index = Before 0
        , current = Nothing
        , pos = 0
        , compare = compare
        }


fromList : (Int -> i -> Order) -> List i -> TimeArray i
fromList compare list =
    TA
        { array = Array.fromList list
        , index = Before 0
        , current = Nothing
        , pos = 0
        , compare = compare
        }


toList : TimeArray i -> List i
toList (TA model) =
    Array.toList model.array


getPos : TimeArray i -> Int
getPos (TA model) =
    model.pos


getCurrent : TimeArray i -> Maybe i
getCurrent (TA model) =
    model.current


getPrevious : TimeArray i -> Maybe i
getPrevious ((TA model) as array) =
    let
        pos =
            case model.index of
                At p ->
                    p - 1

                Before p ->
                    p - 1
    in
    Array.get pos model.array


getNext : TimeArray i -> Maybe i
getNext ((TA model) as array) =
    let
        pos =
            case model.index of
                At p ->
                    p + 1

                Before p ->
                    p
    in
    Array.get pos model.array


updatePos : Int -> TimeArray i -> TimeArray i
updatePos pos ((TA model) as array) =
    let
        ( index, current ) =
            findCurrent pos array
    in
    TA
        { model
            | current = current
            , index = index
            , pos = pos
        }


mapCurrent : (Int -> i) -> (i -> i) -> TimeArray i -> TimeArray i
mapCurrent new function (TA model) =
    let
        current =
            model.current
                |> Maybe.withDefault (new model.pos)
                |> function

        ( newIndex, updatedArray ) =
            case model.index of
                At index ->
                    ( At index, Array.set index current model.array )

                Before index ->
                    ( At index, insertAt index current model.array )
    in
    TA { model | array = updatedArray, current = Just current, index = newIndex }


remove : i -> TimeArray i -> TimeArray i
remove elem ((TA model) as array) =
    TA
        { model
            | array = Array.filter ((/=) elem) model.array
            , current =
                if getCurrent array == Just elem then
                    Nothing

                else
                    model.current
        }


removeCurrent : TimeArray i -> TimeArray i
removeCurrent ((TA model) as array) =
    case getCurrent array of
        Just elem ->
            remove elem array

        _ ->
            array


findCurrent : Int -> TimeArray i -> ( Index, Maybe i )
findCurrent pos (TA model) =
    let
        cmp =
            model.compare pos

        index =
            case model.index of
                At i ->
                    i

                Before i ->
                    i - 1

        current =
            Array.get index model.array

        next =
            Array.get (index + 1) model.array
    in
    case ( Maybe.map cmp current, Maybe.map cmp next ) of
        ( Just EQ, _ ) ->
            ( At index, current )

        ( Just GT, Just LT ) ->
            ( Before index, Nothing )

        ( _, Just EQ ) ->
            ( At (index + 1), next )

        _ ->
            search cmp 0 (Array.length model.array) model.array


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
