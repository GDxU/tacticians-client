module Update.SelectTile exposing (apply_to)

-- Elm -------------------------------------------------------------------------

-- Battlemap -------------------------------------------------------------------
import Struct.Event
import Struct.Location
import Struct.Model
import Struct.Toolbox

--------------------------------------------------------------------------------
-- LOCAL -----------------------------------------------------------------------
--------------------------------------------------------------------------------

--------------------------------------------------------------------------------
-- EXPORTED --------------------------------------------------------------------
--------------------------------------------------------------------------------
apply_to : (
      Struct.Model.Type ->
      Struct.Location.Ref ->
      (Struct.Model.Type, (Cmd Struct.Event.Type))
   )
apply_to model loc_ref =
   let
      (toolbox, map) =
         (Struct.Toolbox.apply_to
            (Struct.Location.from_ref loc_ref)
            model.toolbox
            model.map
         )
   in
      (
         {model |
            toolbox = toolbox,
            map = map
         },
         Cmd.none
      )
