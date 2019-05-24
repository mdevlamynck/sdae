module Benchmarks exposing (main)

import Benchmark exposing (Benchmark, compare, describe)
import Benchmark.Runner exposing (BenchmarkProgram, program)
import Data exposing (Hit(..), Kind(..))
import EverySet
import Inputs
import ReferenceInputs


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

        referenceInputs : Int -> ReferenceInputs.Inputs
        referenceInputs size =
            List.range 0 size
                |> List.map
                    (\pos ->
                        { hits = EverySet.fromList [ LeftUp, RightDown ]
                        , pos = pos * separation
                        , offset = 3
                        , kind = Regular
                        }
                    )
                |> ReferenceInputs.fromList

        inputs : Int -> Inputs.Inputs
        inputs size =
            List.range 0 size
                |> List.map
                    (\pos ->
                        { hits = EverySet.fromList [ LeftUp, RightDown ]
                        , pos = pos * separation
                        , offset = 3
                        , kind = Regular
                        }
                    )
                |> Inputs.fromList

        referenceInputs100 =
            referenceInputs 100

        referenceInputs300 =
            referenceInputs 300

        referenceInputs600 =
            referenceInputs 600

        inputs100 =
            inputs 100

        inputs300 =
            inputs 300

        inputs600 =
            inputs 600

        referenceInputsC100 =
            ReferenceInputs.updatePos ((100 // 2) * separation) referenceInputs100

        referenceInputsC300 =
            ReferenceInputs.updatePos ((300 // 2) * separation) referenceInputs300

        referenceInputsC600 =
            ReferenceInputs.updatePos ((600 // 2) * separation) referenceInputs600

        inputsC100 =
            Inputs.updatePos ((100 // 2) * separation) inputs100

        inputsC300 =
            Inputs.updatePos ((300 // 2) * separation) inputs300

        inputsC600 =
            Inputs.updatePos ((600 // 2) * separation) inputs600

        referenceInputsB100 =
            ReferenceInputs.updatePos ((100 // 2) * separation - between) referenceInputs100

        referenceInputsB300 =
            ReferenceInputs.updatePos ((300 // 2) * separation - between) referenceInputs300

        referenceInputsB600 =
            ReferenceInputs.updatePos ((600 // 2) * separation - between) referenceInputs600

        inputsB100 =
            Inputs.updatePos ((100 // 2) * separation - between) inputs100

        inputsB300 =
            Inputs.updatePos ((300 // 2) * separation - between) inputs300

        inputsB600 =
            Inputs.updatePos ((600 // 2) * separation - between) inputs600

        referenceInputsN100 =
            ReferenceInputs.updatePos ((100 // 2) * separation - separation) referenceInputs100

        referenceInputsN300 =
            ReferenceInputs.updatePos ((300 // 2) * separation - separation) referenceInputs300

        referenceInputsN600 =
            ReferenceInputs.updatePos ((600 // 2) * separation - separation) referenceInputs600

        inputsN100 =
            Inputs.updatePos ((100 // 2) * separation - separation) inputs100

        inputsN300 =
            Inputs.updatePos ((300 // 2) * separation - separation) inputs300

        inputsN600 =
            Inputs.updatePos ((600 // 2) * separation - separation) inputs600
    in
    describe "Inputs"
        [ describe "updatePos"
            [ compare "100"
                "Reference"
                (\_ -> ReferenceInputs.updatePos ((100 // 2) * separation) referenceInputs100)
                "Opimized"
                (\_ -> Inputs.updatePos ((100 // 2) * separation) inputs100)
            , compare "300"
                "Reference"
                (\_ -> ReferenceInputs.updatePos ((300 // 2) * separation) referenceInputs300)
                "Opimized"
                (\_ -> Inputs.updatePos ((300 // 2) * separation) inputs300)
            , compare "600"
                "Reference"
                (\_ -> ReferenceInputs.updatePos ((600 // 2) * separation) referenceInputs600)
                "Opimized"
                (\_ -> Inputs.updatePos ((600 // 2) * separation) inputs600)
            ]
        , describe "updatePos current"
            [ compare "100"
                "Reference"
                (\_ -> ReferenceInputs.updatePos ((100 // 2) * separation) referenceInputsC100)
                "Opimized"
                (\_ -> Inputs.updatePos ((100 // 2) * separation) inputsC100)
            , compare "300"
                "Reference"
                (\_ -> ReferenceInputs.updatePos ((300 // 2) * separation) referenceInputsC300)
                "Opimized"
                (\_ -> Inputs.updatePos ((300 // 2) * separation) inputsC300)
            , compare "600"
                "Reference"
                (\_ -> ReferenceInputs.updatePos ((600 // 2) * separation) referenceInputsC600)
                "Opimized"
                (\_ -> Inputs.updatePos ((600 // 2) * separation) inputsC600)
            ]
        , describe "updatePos between"
            [ compare "100"
                "Reference"
                (\_ -> ReferenceInputs.updatePos ((100 // 2) * separation) referenceInputsB100)
                "Opimized"
                (\_ -> Inputs.updatePos ((100 // 2) * separation) inputsB100)
            , compare "300"
                "Reference"
                (\_ -> ReferenceInputs.updatePos ((300 // 2) * separation) referenceInputsB300)
                "Opimized"
                (\_ -> Inputs.updatePos ((300 // 2) * separation) inputsB300)
            , compare "600"
                "Reference"
                (\_ -> ReferenceInputs.updatePos ((600 // 2) * separation) referenceInputsB600)
                "Opimized"
                (\_ -> Inputs.updatePos ((600 // 2) * separation) inputsB600)
            ]
        , describe "updatePos next"
            [ compare "100"
                "Reference"
                (\_ -> ReferenceInputs.updatePos ((100 // 2) * separation) referenceInputsN100)
                "Opimized"
                (\_ -> Inputs.updatePos ((100 // 2) * separation) inputsN100)
            , compare "300"
                "Reference"
                (\_ -> ReferenceInputs.updatePos ((300 // 2) * separation) referenceInputsN300)
                "Opimized"
                (\_ -> Inputs.updatePos ((300 // 2) * separation) inputsN300)
            , compare "600"
                "Reference"
                (\_ -> ReferenceInputs.updatePos ((600 // 2) * separation) referenceInputsN600)
                "Opimized"
                (\_ -> Inputs.updatePos ((600 // 2) * separation) inputsN600)
            ]
        , describe "mapCurrentInput"
            [ compare "100"
                "Reference"
                (\_ -> ReferenceInputs.mapCurrentInput identity referenceInputs100)
                "Opimized"
                (\_ -> Inputs.mapCurrentInput identity inputs100)
            , compare "300"
                "Reference"
                (\_ -> ReferenceInputs.mapCurrentInput identity referenceInputs300)
                "Opimized"
                (\_ -> Inputs.mapCurrentInput identity inputs300)
            , compare "600"
                "Reference"
                (\_ -> ReferenceInputs.mapCurrentInput identity referenceInputs600)
                "Opimized"
                (\_ -> Inputs.mapCurrentInput identity inputs600)
            ]
        ]
