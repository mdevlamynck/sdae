module Benchmarks exposing (main)

import Benchmark exposing (Benchmark, benchmark, describe)
import Benchmark.Runner exposing (BenchmarkProgram, program)
import Data exposing (Hit(..), Input, Kind(..), compareInput, emptyInput)
import EverySet
import TimeArray


main : BenchmarkProgram
main =
    program suite


suite : Benchmark
suite =
    let
        separation =
            100

        between =
            separation // 2

        inputs : Int -> TimeArray.TimeArray Input
        inputs size =
            List.range 0 size
                |> List.map
                    (\pos ->
                        { hits = EverySet.fromList [ LeftUp, RightDown ]
                        , pos = pos * separation
                        , offset = 3
                        , duration = 0
                        , kind = Regular
                        }
                    )
                |> TimeArray.fromList compareInput

        inputs100 =
            inputs 100

        inputs300 =
            inputs 300

        inputs600 =
            inputs 600

        inputsC100 =
            TimeArray.updatePos ((100 // 2) * separation) inputs100

        inputsC300 =
            TimeArray.updatePos ((300 // 2) * separation) inputs300

        inputsC600 =
            TimeArray.updatePos ((600 // 2) * separation) inputs600

        inputsB100 =
            TimeArray.updatePos ((100 // 2) * separation - between) inputs100

        inputsB300 =
            TimeArray.updatePos ((300 // 2) * separation - between) inputs300

        inputsB600 =
            TimeArray.updatePos ((600 // 2) * separation - between) inputs600

        inputsN100 =
            TimeArray.updatePos ((100 // 2) * separation - separation) inputs100

        inputsN300 =
            TimeArray.updatePos ((300 // 2) * separation - separation) inputs300

        inputsN600 =
            TimeArray.updatePos ((600 // 2) * separation - separation) inputs600
    in
    describe "Inputs"
        [ describe "updatePos"
            [ benchmark "100"
                (\_ -> TimeArray.updatePos ((100 // 2) * separation) inputs100)
            , benchmark "300"
                (\_ -> TimeArray.updatePos ((300 // 2) * separation) inputs300)
            , benchmark "600"
                (\_ -> TimeArray.updatePos ((600 // 2) * separation) inputs600)
            ]
        , describe "updatePos current"
            [ benchmark "100"
                (\_ -> TimeArray.updatePos ((100 // 2) * separation) inputsC100)
            , benchmark "300"
                (\_ -> TimeArray.updatePos ((300 // 2) * separation) inputsC300)
            , benchmark "600"
                (\_ -> TimeArray.updatePos ((600 // 2) * separation) inputsC600)
            ]
        , describe "updatePos between"
            [ benchmark "100"
                (\_ -> TimeArray.updatePos ((100 // 2) * separation) inputsB100)
            , benchmark "300"
                (\_ -> TimeArray.updatePos ((300 // 2) * separation) inputsB300)
            , benchmark "600"
                (\_ -> TimeArray.updatePos ((600 // 2) * separation) inputsB600)
            ]
        , describe "updatePos next"
            [ benchmark "100"
                (\_ -> TimeArray.updatePos ((100 // 2) * separation) inputsN100)
            , benchmark "300"
                (\_ -> TimeArray.updatePos ((300 // 2) * separation) inputsN300)
            , benchmark "600"
                (\_ -> TimeArray.updatePos ((600 // 2) * separation) inputsN600)
            ]
        , describe "mapCurrent"
            [ benchmark "100"
                (\_ -> TimeArray.mapCurrent emptyInput identity inputs100)
            , benchmark "300"
                (\_ -> TimeArray.mapCurrent emptyInput identity inputs300)
            , benchmark "600"
                (\_ -> TimeArray.mapCurrent emptyInput identity inputs600)
            ]
        ]
