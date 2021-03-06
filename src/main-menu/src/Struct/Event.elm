module Struct.Event exposing (Type(..), attempted)

-- Elm -------------------------------------------------------------------------
import Http

-- Main Menu -------------------------------------------------------------------
import Struct.BattleSummary
import Struct.Error
import Struct.BattleRequest
import Struct.MapSummary
import Struct.ServerReply
import Struct.UI

--------------------------------------------------------------------------------
-- TYPES -----------------------------------------------------------------------
--------------------------------------------------------------------------------
type Type =
   None
   | Failed Struct.Error.Type
   | ServerReplied (Result Http.Error (List Struct.ServerReply.Type))
   | NewBattle (Int, Struct.BattleSummary.Category)
   | BattleSetSize Struct.BattleRequest.Size
   | BattleSetMap Struct.MapSummary.Type
   | BattleSetMode Struct.BattleSummary.Mode
   | TabSelected Struct.UI.Tab

attempted : (Result.Result err val) -> Type
attempted act =
   case act of
      (Result.Ok _) -> None
      (Result.Err msg) ->
         (Failed
            (Struct.Error.new
               Struct.Error.Failure
               -- TODO: find a way to get some relevant text here.
               "(text representation not implemented)"
            )
         )
