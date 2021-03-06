module ElmModule.Init exposing (init)

-- Elm -------------------------------------------------------------------------

-- Map -------------------------------------------------------------------
import Comm.LoadBattle

import Struct.Event
import Struct.Flags
import Struct.Model

--------------------------------------------------------------------------------
-- LOCAL -----------------------------------------------------------------------
--------------------------------------------------------------------------------

--------------------------------------------------------------------------------
-- EXPORTED --------------------------------------------------------------------
--------------------------------------------------------------------------------
init : Struct.Flags.Type -> (Struct.Model.Type, (Cmd Struct.Event.Type))
init flags =
   let model = (Struct.Model.new flags) in
      (
         model,
         (case (Comm.LoadBattle.try model) of
            (Just cmd) -> cmd
            Nothing -> Cmd.none
         )
      )
