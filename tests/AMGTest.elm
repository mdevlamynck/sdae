module AMGTest exposing (suite)

import AMG
import Bytes exposing (Bytes)
import Bytes.Encode as Bytes
import Data exposing (..)
import EverySet
import Expect exposing (Expectation)
import Fuzz exposing (Fuzzer, int, list, string)
import Test exposing (..)


emptyGame : Game
emptyGame =
    { stages = [] }


sampleGame : Game
sampleGame =
    { stages =
        [ { level = Easy
          , player = P1
          , maxScore = 42
          , inputs =
                [ { hits = EverySet.fromList [ LeftUp, RightDown ]
                  , pos = 256 / 60
                  , duration = 0.1
                  , kind = Regular
                  }
                , { hits = EverySet.fromList [ LeftUp, RightDown ]
                  , pos = 1024 / 60
                  , duration = 0.1
                  , kind = Regular
                  }
                ]
          }
        , { level = AltSuperHard
          , player = P2
          , maxScore = 24
          , inputs =
                [ { hits = EverySet.fromList [ LeftUp, RightDown ]
                  , pos = 256 / 60
                  , duration = 0.1
                  , kind = Regular
                  }
                , { hits = EverySet.fromList [ LeftUp, RightDown ]
                  , pos = 1024 / 60
                  , duration = 0.1
                  , kind = Regular
                  }
                ]
          }
        ]
    }


suite : Test
suite =
    describe "AMG"
        [ test "Encoded then decoded emptyGame is unchanged" <|
            \_ ->
                emptyGame
                    |> (AMG.encode >> AMG.decode)
                    |> Expect.equal (Just emptyGame)
        , test "Encoded then decoded sampleGame is unchanged" <|
            \_ ->
                sampleGame
                    |> (AMG.encode >> AMG.decode)
                    |> Expect.equal (Just sampleGame)
        ]
