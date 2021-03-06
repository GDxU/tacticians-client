module Update.SetWeapon exposing (apply_to)

-- Elm -------------------------------------------------------------------------
import Dict

-- Roster Editor ---------------------------------------------------------------
import Struct.Character
import Struct.Event
import Struct.Model
import Struct.UI
import Struct.Weapon

--------------------------------------------------------------------------------
-- LOCAL -----------------------------------------------------------------------
--------------------------------------------------------------------------------

--------------------------------------------------------------------------------
-- EXPORTED --------------------------------------------------------------------
--------------------------------------------------------------------------------
apply_to : (
      Struct.Model.Type ->
      Struct.Weapon.Ref ->
      (Struct.Model.Type, (Cmd Struct.Event.Type))
   )
apply_to model ref =
   (
      (
         case (model.edited_char, (Dict.get ref model.weapons)) of
            ((Just char), (Just weapon)) ->
               {model |
                  edited_char =
                     (Just
                        (
                           if (Struct.Character.get_is_using_secondary char)
                           then
                              (Struct.Character.set_secondary_weapon
                                 weapon
                                 char
                              )
                           else
                              (Struct.Character.set_primary_weapon
                                 weapon
                                 char
                              )
                        )
                     )
               }

            _ -> model
      ),
      Cmd.none
   )
