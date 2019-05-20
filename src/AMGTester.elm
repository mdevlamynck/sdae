port module AMGTester exposing (main)

import AMG
import Base64
import Platform


port sendToJs : String -> Cmd msg


port sendToElm : (String -> msg) -> Sub msg


type Msg
    = Msg String


main : Program () () Msg
main =
    Platform.worker
        { init = \_ -> ( (), Cmd.none )
        , update = \(Msg value) _ -> run value |> sendToJs |> (\cmd -> ( (), cmd ))
        , subscriptions = \_ -> sendToElm Msg
        }


run : String -> String
run input =
    case Base64.toBytes input of
        Just file ->
            case AMG.decode file of
                Just game ->
                    case Base64.fromBytes (AMG.encode game) of
                        Just generated ->
                            if generated == input then
                                "Succeeded!"

                            else
                                "Generated file differs!"

                        _ ->
                            "Encoding failed!"

                _ ->
                    "Decoding failed!"

        _ ->
            "Loading failed!"
