----------------------------------------------------------------------
--
-- SimpleMatrix.elm
-- A lighter-weight matrix package than chendrix/elm-matrix.
-- I mostly did it for updateRange, which is highly cool.
-- Copyright (c) 2016 Bill St. Clair <billstclair@gmail.com>
-- Some rights reserved.
-- Distributed under the MIT License
-- See LICENSE.txt
--
----------------------------------------------------------------------

module SimpleMatrix exposing ( Location, Matrix, IntMatrix
                             , loc, row, col
                             , incRow, incCol, incRowBy, incColBy, fill
                             , initialize
                             , rows, cols, get, set
                             , elemIndex, find
                             , updateRange, updateRangeUntil
                             , updateRowRange, updateColRange
                             , updateRowRangeUntil, updateColRangeUntil
                             , updateRowRangeWithValue, updateColRangeWithValue
                             , updateRowRangeWithValueUntil
                             , updateColRangeWithValueUntil
                             )

import Array exposing (Array)

{-
   --
   -- Example
   --

   m: IntMatrix
   m = fill 3 10 0

   m' = updateColRange (1, 2) 5 (\loc m -> col loc) m
   m'' = updateColRangeUntil (1, 2) (\loc -> (col loc) == 7) (\loc m -> col loc) m

-}

type alias Location =
    ( Int, Int )

loc : Int -> Int -> Location
loc row col =
    ( row, col )

row : Location -> Int
row loc =
    Tuple.first loc

col : Location -> Int
col loc =
    Tuple.second loc

incRowBy : Int -> Location -> Location
incRowBy increment loc =
    ( (row loc) + increment, col loc )

incColBy : Int -> Location -> Location
incColBy increment loc =
    ( row loc, (col loc) + increment )

incRow : Location -> Location
incRow loc =
    incRowBy 1 loc

incCol : Location -> Location
incCol loc =
    incColBy 1 loc

type alias Matrix a =
    Array (Array a)

type alias IntMatrix =
    Matrix Int

fill : Int -> Int -> a -> Matrix a
fill rows cols value =
    Array.repeat cols value
        |> Array.repeat rows

initializeCols : Int -> Int -> Int -> (Location -> a) -> Array a -> Array a
initializeCols rowidx colidx cols initializer row =
    if colidx >= cols then
        row
    else
        let value = initializer ( rowidx, colidx )
        in
            initializeCols
                rowidx
                (colidx + 1)
                cols
                initializer
                (Array.set colidx value row)

initializeRows : Int -> Int -> Int -> (Location -> a) -> Matrix a -> Matrix a
initializeRows rowidx rows cols initializer res =
    if rowidx >= rows then
        res
    else
        let row = Array.get rowidx res
            res_ =
                case row of
                    Nothing -> res
                    Just r ->
                        let
                            row_ =
                                initializeCols rowidx 0 cols initializer r
                        in
                            (Array.set rowidx row_ res)
        in
            initializeRows
                (rowidx + 1)
                rows
                cols
                initializer
                res_

initialize : Int -> Int -> (Location -> a) -> Matrix a
initialize rows cols initializer =
    let default = initializer ( 0, 0 )
        res = fill rows cols default
    in
        initializeRows 0 rows cols initializer res

rows : Matrix a -> Int
rows matrix =
    Array.length matrix

cols : Matrix a -> Int
cols matrix =
    let row = Array.get 0 matrix
    in
        case row of
            Nothing -> 0
            Just row ->
                Array.length row

get : Location -> Matrix a -> Maybe a
get loc matrix =
    let ( rowidx, colidx ) = loc
    in
        case Array.get rowidx matrix of
            Nothing -> Nothing
            Just r ->
                case Array.get colidx r of
                    Nothing -> Nothing
                    something -> something

set : Location -> a -> Matrix a -> Matrix a
set loc val matrix =
    let ( rowidx, colidx ) = loc
    in
        case Array.get rowidx matrix of
            Nothing -> matrix
            Just r ->
                Array.set rowidx (Array.set colidx val r) matrix

indexColLoop : Int -> Int -> Int -> (a -> Bool) -> Array a -> Maybe ( Location, a )
indexColLoop rowidx colidx cols pred row =
    if colidx >= cols then
        Nothing
    else
        case Array.get colidx row of
            Nothing -> Nothing
            Just e ->
                if pred e then
                    Just ( ( rowidx, colidx ), e )
                else
                    indexColLoop rowidx (colidx + 1) cols pred row

indexRowLoop : Int -> Int -> (a -> Bool) -> Matrix a -> Maybe ( Location, a )
indexRowLoop rowidx rows pred matrix =
    if rowidx >= rows then
        Nothing
    else
        case Array.get rowidx matrix of
            Nothing -> Nothing
            Just r ->
                case indexColLoop rowidx 0 (cols matrix) pred r of
                    Nothing ->
                        indexRowLoop (rowidx + 1) rows pred matrix
                    something ->
                        something

elemIndex : a -> Matrix a -> Maybe Location
elemIndex elem matrix =
    case indexRowLoop 0 (rows matrix) (\x -> x == elem) matrix of
        Nothing -> Nothing
        Just pair ->
            Just (Tuple.first pair)

find : (a -> Bool) -> Matrix a -> Maybe a
find pred matrix =
    case indexRowLoop 0 (rows matrix) pred matrix of
        Nothing -> Nothing
        Just pair ->
            Just (Tuple.second pair)

updateRange : a -> (a -> a) -> Int -> (a -> b -> b) -> b -> b
updateRange start incrementor count updater thing =
    if count <= 0 then
        thing
    else
        updateRange
            (incrementor start)
            incrementor
            (count - 1)
            updater
            (updater start thing)

updateRangeUntil : a -> (a -> a) -> (a -> Bool) -> (a -> b -> b) -> b -> b
updateRangeUntil start incrementor predicate updater thing =
    if predicate start then
        thing
    else
        updateRangeUntil
            (incrementor start)
            incrementor
            predicate
            updater
            (updater start thing)

updateRowRange : Location -> Int -> (Location -> Matrix a -> Matrix a) -> Matrix a -> Matrix a
updateRowRange loc count updater matrix =
    updateRange loc incRow count updater matrix

updateColRange : Location -> Int -> (Location -> Matrix a -> Matrix a) -> Matrix a -> Matrix a
updateColRange loc count updater matrix =
    updateRange loc incCol count updater matrix

updateRowRangeUntil : Location -> (Location -> Bool) -> (Location -> Matrix a -> Matrix a) -> Matrix a -> Matrix a
updateRowRangeUntil loc predicate updater matrix =
    updateRangeUntil loc incRow predicate updater matrix

updateColRangeUntil : Location -> (Location -> Bool) -> (Location -> Matrix a -> Matrix a) -> Matrix a -> Matrix a
updateColRangeUntil loc predicate updater matrix =
    updateRangeUntil loc incCol predicate updater matrix

valueUpdater : a -> Location -> Matrix a -> Matrix a
valueUpdater value loc matrix =
    let rowidx = (row loc)
        r = Array.get rowidx matrix
    in
        case r of
            Nothing -> matrix
            Just r_ ->
                Array.set rowidx (Array.set (col loc) value r_) matrix

updateRowRangeWithValue : Location -> Int -> a -> Matrix a -> Matrix a
updateRowRangeWithValue loc count value matrix =
    updateRowRange loc count (valueUpdater value) matrix

updateColRangeWithValue : Location -> Int -> a -> Matrix a -> Matrix a
updateColRangeWithValue loc count value matrix =
    updateColRange loc count (valueUpdater value) matrix

updateRowRangeWithValueUntil : Location -> (Location -> Bool) -> a -> Matrix a -> Matrix a
updateRowRangeWithValueUntil loc predicate value matrix =
    updateRowRangeUntil loc predicate (valueUpdater value) matrix

updateColRangeWithValueUntil : Location -> (Location -> Bool) -> a -> Matrix a -> Matrix a
updateColRangeWithValueUntil loc predicate value matrix =
    updateColRangeUntil loc predicate (valueUpdater value) matrix
