module Element.Utils exposing (attrWhen, checked, elWhen, elWhenJust, tag)

import Element exposing (..)
import Html.Attributes exposing (attribute, class, property)
import Json.Encode exposing (bool)


elWhen : Bool -> Element msg -> Element msg
elWhen predicate view =
    if predicate then
        view

    else
        none


elWhenJust : Maybe a -> (a -> Element msg) -> Element msg
elWhenJust maybe view =
    case maybe of
        Just a ->
            view a

        Nothing ->
            none


attrWhen : Bool -> Attribute msg -> Attribute msg
attrWhen predicate attr =
    if predicate then
        attr

    else
        htmlAttribute <| class ""


tag : String -> Attribute msg
tag t =
    htmlAttribute <| attribute "data-cy" t


checked : Bool -> Attribute msg
checked isChecheked =
    htmlAttribute <| property "checked" (bool isChecheked)
