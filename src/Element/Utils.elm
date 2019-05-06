module Element.Utils exposing (active, checked, elWhenJust)

import Element exposing (..)
import Html.Attributes exposing (property)
import Json.Encode exposing (bool)


elWhenJust : Maybe a -> (a -> Element msg) -> Element msg
elWhenJust maybe view =
    case maybe of
        Just a ->
            view a

        Nothing ->
            none


checked : Bool -> Attribute msg
checked isChecheked =
    htmlAttribute <| property "checked" (bool isChecheked)


active : Bool -> Attribute msg
active isActive =
    htmlAttribute <| property "active" (bool isActive)
