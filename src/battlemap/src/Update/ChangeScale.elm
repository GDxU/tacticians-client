module Update.ChangeScale exposing (apply_to)
-- Elm -------------------------------------------------------------------------

-- Battlemap -------------------------------------------------------------------
import Struct.Event
import Struct.Model
import Struct.UI

--------------------------------------------------------------------------------
-- LOCAL -----------------------------------------------------------------------
--------------------------------------------------------------------------------

--------------------------------------------------------------------------------
-- EXPORTED --------------------------------------------------------------------
--------------------------------------------------------------------------------
apply_to : (
      Struct.Model.Type ->
      Float ->
      (Struct.Model.Type, (Cmd Struct.Event.Type))
   )
apply_to model mod =
   if (mod == 0.0)
   then
      ({model | ui = (Struct.UI.reset_zoom_level model.ui)}, Cmd.none)
   else
      ({model | ui = (Struct.UI.mod_zoom_level model.ui mod)}, Cmd.none)
