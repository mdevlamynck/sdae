module AMGTest exposing (suite)

import AMG
import Bytes exposing (Bytes)
import Bytes.Encode as Bytes
import Data exposing (Game)
import Expect exposing (Expectation)
import Fuzz exposing (Fuzzer, int, list, string)
import Test exposing (..)


emptyGame : Game
emptyGame =
    {}


emptyFile : Bytes
emptyFile =
    Bytes.encode (Bytes.sequence [])


suite : Test
suite =
    describe "AMG"
        [ describe "encoder"
            [ test "does nothing at the moment" <|
                \_ ->
                    AMG.encode emptyGame
                        |> Expect.equal emptyFile
            ]
        , describe "decoder"
            [ test "does nothing at the moment" <|
                \_ ->
                    AMG.decode emptyFile
                        |> Expect.equal Nothing
            ]
        ]
