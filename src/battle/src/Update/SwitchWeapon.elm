module Update.SwitchWeapon exposing (apply_to)

-- Elm -------------------------------------------------------------------------

-- Battle ----------------------------------------------------------------------
import Struct.Character
import Struct.CharacterTurn
import Struct.Error
import Struct.Event
import Struct.Model
import Struct.Navigator
import Struct.Weapon
import Struct.WeaponSet

--------------------------------------------------------------------------------
-- LOCAL -----------------------------------------------------------------------
--------------------------------------------------------------------------------
make_it_so : Struct.Model.Type -> Struct.Model.Type
make_it_so model =
   case
      (
         (Struct.CharacterTurn.try_getting_active_character model.char_turn),
         (Struct.CharacterTurn.try_getting_navigator model.char_turn)
      )
   of
      ((Just char), (Just nav)) ->
         let
            tile_omnimods = (Struct.Model.tile_omnimods_fun model)
            current_tile_omnimods =
               (tile_omnimods (Struct.Navigator.get_current_location nav))
            new_weapons =
               (Struct.WeaponSet.switch_weapons
                  (Struct.Character.get_weapons char)
               )
            new_main_weapon = (Struct.WeaponSet.get_active_weapon new_weapons)
            new_char =
               (Struct.Character.refresh_omnimods
                  (\e -> current_tile_omnimods)
                  (Struct.Character.set_weapons new_weapons char)
               )
         in
            {model |
               char_turn =
                  (Struct.CharacterTurn.set_has_switched_weapons
                     True
                     (Struct.CharacterTurn.show_attack_range_navigator
                        (Struct.Weapon.get_defense_range new_main_weapon)
                        (Struct.Weapon.get_attack_range new_main_weapon)
                        (Struct.CharacterTurn.set_active_character_no_reset
                           new_char
                           model.char_turn
                        )
                     )
                  )
            }

      (_, _) ->
         (Struct.Model.invalidate
            (Struct.Error.new
               Struct.Error.Programming
               """
               CharacterTurn structure in the 'SelectedCharacter' or
               'MovedCharacter' state without any character being selected.
               """)
            model
         )

--------------------------------------------------------------------------------
-- EXPORTED --------------------------------------------------------------------
--------------------------------------------------------------------------------
apply_to : (
      Struct.Model.Type ->
      (Struct.Model.Type, (Cmd Struct.Event.Type))
   )
apply_to model =
   case (Struct.CharacterTurn.get_state model.char_turn) of
      Struct.CharacterTurn.SelectedCharacter ->
         ((make_it_so model), Cmd.none)

      Struct.CharacterTurn.MovedCharacter ->
         ((make_it_so model), Cmd.none)

      _ ->
         (
            (Struct.Model.invalidate
               (Struct.Error.new
                  Struct.Error.Programming
                  (
                     "Attempt to switch weapons as a secondary action or"
                     ++ " without character being selected."
                  )
               )
               model
            ),
            Cmd.none
         )
