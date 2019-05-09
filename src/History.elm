module History exposing (History(..), empty, record, redo, undo)

import Array exposing (Array)


type History a
    = H { history : Array a, pos : Int }


empty : History a
empty =
    H { history = Array.empty, pos = 0 }


record : a -> History a -> History a
record a (H model) =
    let
        pos =
            model.pos + 1
    in
    H
        { model
            | history = model.history |> Array.slice 0 model.pos |> Array.push a
            , pos = pos
        }


undo : History a -> ( History a, Maybe a )
undo (H model) =
    let
        pos =
            model.pos - 1 |> keepInRange model.history
    in
    ( H { model | pos = pos }
    , getAt pos model.history
    )


redo : History a -> ( History a, Maybe a )
redo (H model) =
    let
        pos =
            model.pos + 1 |> keepInRange model.history
    in
    ( H { model | pos = pos }
    , getAt pos model.history
    )


getAt : Int -> Array a -> Maybe a
getAt pos history =
    Array.get (pos - 1) history


keepInRange : Array a -> Int -> Int
keepInRange history pos =
    between 0 (Array.length history) pos


between : Int -> Int -> Int -> Int
between low high =
    min high << max low
