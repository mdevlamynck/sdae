module Element.Utils exposing (elWhenJust)

import Element exposing (..)


elWhenJust : Maybe a -> (a -> Element msg) -> Element msg
elWhenJust maybe view =
    case maybe of
        Just a ->
            view a

        Nothing ->
            none
