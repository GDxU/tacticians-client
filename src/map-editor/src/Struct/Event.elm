module Struct.Event exposing (Type(..), attempted)

-- Elm -------------------------------------------------------------------------
import Http

-- Battlemap -------------------------------------------------------------------
import Struct.Error
import Struct.HelpRequest
import Struct.Location
import Struct.ServerReply
import Struct.Tile
import Struct.Toolbox
import Struct.UI

--------------------------------------------------------------------------------
-- TYPES -----------------------------------------------------------------------
--------------------------------------------------------------------------------
type Type =
   None
   | Failed Struct.Error.Type
   | ScaleChangeRequested Float
   | ServerReplied (Result Http.Error (List Struct.ServerReply.Type))
   | TabSelected Struct.UI.Tab
   | TileSelected Struct.Location.Ref
   | RequestedHelp Struct.HelpRequest.Type
   | ModeRequested Struct.Toolbox.Mode
   | ShapeRequested Struct.Toolbox.Shape
   | ClearSelectionRequested
   | TemplateRequested (Struct.Tile.Ref, Struct.Tile.VariantID)
   | PrettifySelectionRequested
   | SendMapUpdateRequested
   | GoToMainMenu

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
