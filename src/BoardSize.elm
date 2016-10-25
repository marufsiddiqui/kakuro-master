----------------------------------------------------------------------
--
-- BoardSize.elm
-- Size the elements of the board and keypad
-- Copyright (c) 2016 Bill St. Clair <billstclair@gmail.com>
-- Some rights reserved.
-- Distributed under the MIT License
-- See LICENSE.txt
--
----------------------------------------------------------------------

module BoardSize exposing ( computeBoardSizes
                          , Rect, cellRect, cellTextLocation
                          , insetRectForSelection
                          , bottomLabelLocation, rightLabelLocation
                          , labelBackgroundRect
                          , hintTextLocation)

import SharedTypes exposing ( Model, BoardSizes )

import Window
import Debug exposing (log)

cellBorder : Int
cellBorder = 1

labelBackgroundInset : Int
labelBackgroundInset = 1

selectionBorder : Int
selectionBorder = 3

whiteSpace : Int
whiteSpace = 1

minimumCellSize : Int
minimumCellSize = 20

maximumCellSize : Int
maximumCellSize = 80

minimumFontSize : Int
minimumFontSize = 8

minimumPossibilitiesHeight : Int
minimumPossibilitiesHeight = 60

keypadRows: Int
keypadRows = 4

maxKeypadSize : Int
maxKeypadSize = 300

defaultWindowSize : Window.Size
defaultWindowSize = { width = 1024, height = 768 }

getWindowSize : Model -> Window.Size
getWindowSize model =
  log "WindowSize" (
  case model.windowSize of
      Nothing -> defaultWindowSize
      Just ws -> ws
                   )

computeCellSize : Model -> Int
computeCellSize model =
  let windowSize = getWindowSize model
      rows = model.kind+1
      h = windowSize.height
      total = min (windowSize.width - 10) <| h - ( 5 * h // ( rows + 5))
      total' = min total (h * 2 // 3)
      size = (total' - 2*(cellBorder + whiteSpace)) // rows
  in
      max minimumCellSize size
        |> min maximumCellSize

boardFromCellSize : Model -> Int -> Int
boardFromCellSize model cellSize =
  (cellSize * (model.kind+1)) + (cellBorder + whiteSpace)

computeBoardSize : Model -> Int
computeBoardSize model =
  computeCellSize model
    |> boardFromCellSize model
      
computeBoardSizes : Model -> BoardSizes
computeBoardSizes model =
  let cellSize = computeCellSize model
      boardSize = log "boardSize" (boardFromCellSize model cellSize)
      cellFontSize = cellSize // 2
      labelFontSize = cellSize // 4
      hintFontSize = labelFontSize
      windowSize = log "windowSize" (getWindowSize model)
      keypadSize = min maxKeypadSize
                   <| 9 * (windowSize.height - boardSize - 50) // 10
  in
      { boardSize = boardSize
      , cellSize = cellSize
      , cellFontSize = cellFontSize
      , labelFontSize = labelFontSize
      , hintFontSize = hintFontSize
      , keypadSize = keypadSize
      , keypadFontSize = (2 * keypadSize) // (keypadRows * 3)
      }
                   
type alias Rect =
  { x : Int
  , y : Int
  , w : Int
  , h : Int
  }

cellRect : Int -> Int -> BoardSizes -> Rect
cellRect row col sizes =
  let cellSize = sizes.cellSize
      offset = cellBorder + whiteSpace
      y = row*cellSize + offset
      x = col*cellSize + offset
      w = cellSize - offset
      h = cellSize - offset
  in
      { x = x, y = y, w = w, h = h}

insetRectForSelection : Rect -> Rect
insetRectForSelection rect =
  let delta = selectionBorder - cellBorder - 1
      x = rect.x + delta
      y = rect.y + delta
      w = rect.w - 2*delta
      h = rect.h - 2*delta
  in
      { x = x, y = y, w = w, h = h }

cellTextLocation : Rect -> (Int, Int)
cellTextLocation cellRect =
  ( cellRect.x + (cellRect.w * 37 // 97)
  , cellRect.y + (cellRect.h * 65 // 97)
  )

bottomLabelLocation : Rect -> (Int, Int)
bottomLabelLocation cellRect =
  ( cellRect.x + (cellRect.w * 25 // 97)
  , cellRect.y + (cellRect.h * 78 // 97)
  )
  
rightLabelLocation : Rect -> (Int, Int)
rightLabelLocation cellRect =
  ( cellRect.x + (cellRect.w * 60 // 97)
  , cellRect.y + (cellRect.h * 44 // 97)
  )

hintToRow : Int -> Int
hintToRow hint =
  if hint < 4 then
    0
  else if hint < 7 then
    1
  else
    2

hintToCol : Int -> Int
hintToCol hint =
  (hint-1) % 3

hintColToTextX : Int -> Int
hintColToTextX hintCol =
  if hintCol == 0 then
    16
  else if hintCol == 1 then
    42
  else
    69
hintRowToTextY : Int -> Int
hintRowToTextY hintRow =
  if hintRow == 0 then
    27
  else if hintRow == 1 then
    57
  else
    87

hintTextLocation : Int -> Rect -> (Int, Int)
hintTextLocation hint cellRect =
  let row = hintToRow hint
      col = hintToCol hint
      x = hintColToTextX col
      y = hintRowToTextY row
  in
      ( cellRect.x + (cellRect.w * x // 97)
      , cellRect.y + (cellRect.h * y // 97)
      )

labelBackgroundRect : Rect -> Rect
labelBackgroundRect rect =
  { x = rect.x + labelBackgroundInset
  , y = rect.y + labelBackgroundInset
  , w = rect.w - 2*labelBackgroundInset
  , h = rect.h - 2*labelBackgroundInset
  }
