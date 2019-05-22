module AMG.Bitwise exposing (bit, set, u4)

import Bitwise exposing (..)


bit : Int -> Int -> Bool
bit offset u32 =
    u32
        |> shiftRightBy offset
        |> and 0x01
        |> (==) 1


u4 : Int -> Int -> Int
u4 offset u32 =
    u32
        |> shiftRightBy offset
        |> and 0x0F


set : Int -> Bool -> Int -> Int
set offset value u32 =
    let
        mask =
            2 ^ offset
    in
    if value then
        u32 |> or mask

    else
        u32 |> and (complement mask)
