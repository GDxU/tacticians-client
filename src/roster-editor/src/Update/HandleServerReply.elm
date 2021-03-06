module Update.HandleServerReply exposing (apply_to)

-- Elm -------------------------------------------------------------------------
import Dict

import Http

import Url
-- Shared ----------------------------------------------------------------------
import Action.Ports

import Struct.Flags

import Util.Http

-- Roster Editor ---------------------------------------------------------------
import Constants.IO

import Struct.Armor
import Struct.CharacterRecord
import Struct.Error
import Struct.Event
import Struct.Glyph
import Struct.GlyphBoard
import Struct.Inventory
import Struct.Model
import Struct.Portrait
import Struct.ServerReply
import Struct.Weapon

--------------------------------------------------------------------------------
-- TYPES -----------------------------------------------------------------------
--------------------------------------------------------------------------------

--------------------------------------------------------------------------------
-- LOCAL -----------------------------------------------------------------------
--------------------------------------------------------------------------------
weapon_getter : Struct.Model.Type -> Struct.Weapon.Ref -> Struct.Weapon.Type
weapon_getter model ref =
   case (Dict.get ref model.weapons) of
      (Just w) -> w
      Nothing -> Struct.Weapon.none

armor_getter : Struct.Model.Type -> Struct.Armor.Ref -> Struct.Armor.Type
armor_getter model ref =
   case (Dict.get ref model.armors) of
      (Just w) -> w
      Nothing -> Struct.Armor.none

portrait_getter : (
      Struct.Model.Type ->
      Struct.Portrait.Ref ->
      Struct.Portrait.Type
   )
portrait_getter model ref =
   case (Dict.get ref model.portraits) of
      (Just w) -> w
      Nothing -> Struct.Portrait.default

-----------

disconnected : (
      (Struct.Model.Type, (List (Cmd Struct.Event.Type))) ->
      (Struct.Model.Type, (List (Cmd Struct.Event.Type)))
   )
disconnected current_state =
   let (model, cmds) = current_state in
      (
         model,
         [
            (Action.Ports.go_to
               (
                  Constants.IO.base_url
                  ++ "/login/?action=disconnect&goto="
                  ++
                  (Url.percentEncode
                     (
                        "/roster-editor/?"
                        ++ (Struct.Flags.get_params_as_url model.flags)
                     )
                  )
               )
            )
         ]
      )

goto : (
      String ->
      (Struct.Model.Type, (List (Cmd Struct.Event.Type))) ->
      (Struct.Model.Type, (List (Cmd Struct.Event.Type)))
   )
goto url current_state =
   let (model, cmds) = current_state in
      (
         model,
         [
            (Action.Ports.go_to (Constants.IO.base_url ++ "/" ++ url))
         ]
      )

add_armor : (
      Struct.Armor.Type ->
      (Struct.Model.Type, (List (Cmd Struct.Event.Type))) ->
      (Struct.Model.Type, (List (Cmd Struct.Event.Type)))
   )
add_armor ar current_state =
   let (model, cmds) = current_state in
      ((Struct.Model.add_armor ar model), cmds)

add_portrait : (
      Struct.Portrait.Type ->
      (Struct.Model.Type, (List (Cmd Struct.Event.Type))) ->
      (Struct.Model.Type, (List (Cmd Struct.Event.Type)))
   )
add_portrait pt current_state =
   let (model, cmds) = current_state in
      ((Struct.Model.add_portrait pt model), cmds)

add_glyph : (
      Struct.Glyph.Type ->
      (Struct.Model.Type, (List (Cmd Struct.Event.Type))) ->
      (Struct.Model.Type, (List (Cmd Struct.Event.Type)))
   )
add_glyph gl current_state =
   let (model, cmds) = current_state in
      ((Struct.Model.add_glyph gl model), cmds)

add_glyph_board : (
      Struct.GlyphBoard.Type ->
      (Struct.Model.Type, (List (Cmd Struct.Event.Type))) ->
      (Struct.Model.Type, (List (Cmd Struct.Event.Type)))
   )
add_glyph_board glb current_state =
   let (model, cmds) = current_state in
      ((Struct.Model.add_glyph_board glb model), cmds)

add_weapon : (
      Struct.Weapon.Type ->
      (Struct.Model.Type, (List (Cmd Struct.Event.Type))) ->
      (Struct.Model.Type, (List (Cmd Struct.Event.Type)))
   )
add_weapon wp current_state =
   let (model, cmds) = current_state in
      ((Struct.Model.add_weapon wp model), cmds)

set_inventory : (
      Struct.Inventory.Type ->
      (Struct.Model.Type, (List (Cmd Struct.Event.Type))) ->
      (Struct.Model.Type, (List (Cmd Struct.Event.Type)))
   )
set_inventory inv current_state =
   let (model, cmds) = current_state in
      ({model | inventory = inv}, cmds)

add_character : (
      Struct.CharacterRecord.Type ->
      (Struct.Model.Type, (List (Cmd Struct.Event.Type))) ->
      (Struct.Model.Type, (List (Cmd Struct.Event.Type)))
   )
add_character char current_state =
   let (model, cmds) = current_state in
      (
         (Struct.Model.add_character_record char model),
         cmds
      )

apply_command : (
      Struct.ServerReply.Type ->
      (Struct.Model.Type, (List (Cmd Struct.Event.Type))) ->
      (Struct.Model.Type, (List (Cmd Struct.Event.Type)))
   )
apply_command command current_state =
   case command of
      Struct.ServerReply.Disconnected -> (disconnected current_state)

      (Struct.ServerReply.GoTo url) -> (goto url current_state)

      (Struct.ServerReply.AddWeapon wp) ->
         (add_weapon wp current_state)

      (Struct.ServerReply.SetInventory inv) ->
         (set_inventory inv current_state)

      (Struct.ServerReply.AddArmor ar) ->
         (add_armor ar current_state)

      (Struct.ServerReply.AddPortrait pt) ->
         (add_portrait pt current_state)

      (Struct.ServerReply.AddGlyph gl) ->
         (add_glyph gl current_state)

      (Struct.ServerReply.AddGlyphBoard glb) ->
         (add_glyph_board glb current_state)

      (Struct.ServerReply.AddCharacter char) ->
         (add_character char current_state)


      Struct.ServerReply.Okay ->
         let (model, cmds) = current_state in
            (
               (Struct.Model.enable_character_records model),
               cmds
            )

--------------------------------------------------------------------------------
-- EXPORTED --------------------------------------------------------------------
--------------------------------------------------------------------------------
apply_to : (
      Struct.Model.Type ->
      (Result Http.Error (List Struct.ServerReply.Type)) ->
      (Struct.Model.Type, (Cmd Struct.Event.Type))
   )
apply_to model query_result =
   case query_result of
      (Result.Err error) ->
         (
            (Struct.Model.invalidate
               (Struct.Error.new
                  Struct.Error.Networking
                  (Util.Http.error_to_string error)
               )
               model
            ),
            Cmd.none
         )

      (Result.Ok commands) ->
         let
            (new_model, elm_commands) =
               (List.foldl (apply_command) (model, [Cmd.none]) commands)
         in
            (
               new_model,
               (
                  case elm_commands of
                     [] -> Cmd.none
                     [cmd] -> cmd
                     _ -> (Cmd.batch elm_commands)
               )
            )
