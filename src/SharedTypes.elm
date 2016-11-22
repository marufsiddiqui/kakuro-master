----------------------------------------------------------------------
--
-- SharedTypes.elm
-- Shared types
-- Copyright (c) 2016 Bill St. Clair <billstclair@gmail.com>
-- Some rights reserved.
-- Distributed under the MIT License
-- See LICENSE.txt
--
----------------------------------------------------------------------

module SharedTypes exposing ( SavedModel, ModelTimes, Model
                            , emptyModelTimes, modelToSavedModel, savedModelToModel
                            , BoardSizes
                            , Msg, Msg(..)
                            , Selection, GameStateTimes, GameState, Flags
                            , IntBoard, BClassMatrix, BClassBoard
                            , Labels, LabelsBoard, Hints, HintsBoard
                            )

import SimpleMatrix exposing (Matrix)
import Styles.Board exposing (BClass)
import Board exposing (Board)
import PuzzleDB
import Random
import Time exposing (Time, second)
import Keyboard
import Window

-- This gets saved in the browser database.
-- Changing it currently causes all saved state to be lost.
-- Fix that eventually.

type alias SavedModel =
    { kind : Int
    , index : Int
    , gencount : Int
    , gameState : GameState
    , timestamp : Time
    }

type alias BoardSizes =
    { boardSize : Int
    , cellSize : Int
    , cellFontSize : Int
    , labelFontSize : Int
    , hintFontSize : Int
    , keypadSize : Int
    , keypadFontSize : Int
    }

type alias ModelTimes =
    { timestamp : Time
    , lastPersist : Maybe Time
    }

emptyModelTimes : ModelTimes
emptyModelTimes =
    ModelTimes 0 Nothing

type alias Model =
    { -- on disk. Copied to and from SavedModel instance.
      kind : Int
    , index : Int
    , gencount : Int
    , gameState : GameState
    -- in-memory only
    , times : ModelTimes
    , windowSize : Maybe Window.Size
    , boardSizes : Maybe BoardSizes
    , seed : Maybe Random.Seed
    , awaitingCommand : Maybe String
    , message : Maybe String
    , shifted : Bool
    }

modelToSavedModel : Model -> SavedModel
modelToSavedModel model =
    { kind = model.kind
    , index = model.index
    , gencount = model.gencount
    , gameState = model.gameState
    , timestamp = model.times.timestamp
    }

savedModelToModel : SavedModel -> Model
savedModelToModel savedModel =
    { kind = savedModel.kind
    , index = savedModel.index
    , gencount = savedModel.gencount
    , gameState = savedModel.gameState
    , times = emptyModelTimes
    , boardSizes = Nothing
    , windowSize = Nothing
    , seed = Nothing
    , awaitingCommand = Nothing
    , message = Nothing
    , shifted = False
    }

type Msg
    = Generate Int
    | Restart
    | ChangeKind Int
    | Tick Time
    | Seed Time
    | ClickCell String
    | PressKey Keyboard.KeyCode
    | DownKey Keyboard.KeyCode
    | UpKey Keyboard.KeyCode
    | ToggleHintInput
    | ToggleShowPossibilities
    | ReceiveGame (Maybe String)
    | AnswerConfirmed String Bool
    | WindowSize Window.Size
    | Nop

type alias IntBoard =
    Board Int

type alias Labels =
    ( Int, Int )

type alias LabelsBoard =
    Board Labels

type alias Hints =
    List Int

type alias HintsBoard =
    Board Hints

type alias Selection =
    ( Int, Int )

type alias BClassMatrix =
    Matrix (Maybe BClass)

type alias BClassBoard =
    Board (Maybe BClass)

type alias Flags =
    { isHintInput : Bool
    , showPossibilities : Bool
    }

type alias GameStateTimes =
    { timestamp: Time
    , elapsed: Time
    }

type alias GameState =
    { board : IntBoard
    , labels : LabelsBoard
    , allDone : Bool
    , guesses : IntBoard
    , hints : HintsBoard
    , flags : Flags
    , selection : Maybe Selection
    , times: GameStateTimes
    }
