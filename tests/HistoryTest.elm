module HistoryTest exposing (historyAtBeginning, historyAtEnd, historyAtMiddle, suite)

import Expect exposing (Expectation)
import History exposing (History)
import Test exposing (..)


historyAtEnd : History Int
historyAtEnd =
    History.empty
        |> History.record 1
        |> History.record 2


historyAtMiddle : History Int
historyAtMiddle =
    historyAtEnd
        |> History.undo
        |> Tuple.first


historyAtBeginning : History Int
historyAtBeginning =
    historyAtMiddle
        |> History.undo
        |> Tuple.first


historyAlternateHistory : History Int
historyAlternateHistory =
    History.empty
        |> History.record 1
        |> History.record 3


suite : Test
suite =
    describe "History"
        [ test "Empty history remains unchanged on undo with empty previous" <|
            \_ ->
                History.empty
                    |> History.undo
                    |> Expect.equal ( History.empty, Nothing )
        , test "Empty history remains unchanged on redo with empty previous" <|
            \_ ->
                History.empty
                    |> History.redo
                    |> Expect.equal ( History.empty, Nothing )
        , test "Undo returns the previous state" <|
            \_ ->
                historyAtEnd
                    |> History.undo
                    |> Tuple.second
                    |> Expect.equal (Just 1)
        , test "Undo twice returns nothing (no previous state)" <|
            \_ ->
                historyAtMiddle
                    |> History.undo
                    |> Tuple.second
                    |> Expect.equal Nothing
        , test "Undo beyond history is noop" <|
            \_ ->
                historyAtBeginning
                    |> History.undo
                    |> Tuple.first
                    |> Expect.equal historyAtBeginning
        , test "Redo beyond history is noop" <|
            \_ ->
                historyAtEnd
                    |> History.redo
                    |> Tuple.first
                    |> Expect.equal historyAtEnd
        , test "Undo then redo is noop" <|
            \_ ->
                historyAtBeginning
                    |> History.redo
                    |> Tuple.first
                    |> History.redo
                    |> Tuple.first
                    |> Expect.equal historyAtEnd
        , test "Undo then edit removes old redos" <|
            \_ ->
                historyAtMiddle
                    |> History.record 3
                    |> Expect.equal historyAlternateHistory
        , test "Undo then edit then undo" <|
            \_ ->
                historyAlternateHistory
                    |> History.undo
                    |> Tuple.second
                    |> Expect.equal (Just 1)
        ]
