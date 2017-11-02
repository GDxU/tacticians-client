module Update exposing (update)

import Event

import Error

import UI

import Model
import Model.RequestDirection
import Model.SelectTile
import Model.SelectCharacter
import Model.EndTurn

import Send.CharacterTurn

update : Event.Type -> Model.Type -> (Model.Type, (Cmd Event.Type))
update event model =
   let
      new_model = (Model.clear_error model)
   in
   case event of
      (Event.DirectionRequested d) ->
         ((Model.RequestDirection.apply_to new_model d), Cmd.none)

      (Event.TileSelected loc) ->
         ((Model.SelectTile.apply_to new_model loc), Cmd.none)

      (Event.CharacterSelected char_id) ->
         ((Model.SelectCharacter.apply_to new_model char_id), Cmd.none)

      Event.TurnEnded ->
         (
            (Model.EndTurn.apply_to new_model),
--            Cmd.none
            (case (Send.CharacterTurn.try_sending model) of
               (Just cmd) -> cmd
               Nothing -> Cmd.none
            )
         )

      (Event.ScaleChangeRequested mod) ->
         if (mod == 0.0)
         then
            ({model | ui = (UI.reset_zoom_level model.ui)}, Cmd.none)
         else
            ({model | ui = (UI.mod_zoom_level model.ui mod)}, Cmd.none)

      (Event.TabSelected tab) ->
            ({model | ui = (UI.set_displayed_tab model.ui tab)}, Cmd.none)

      (Event.DebugTeamSwitchRequest) ->
         if (model.controlled_team == 0)
         then
            (
               (Model.reset {model | controlled_team = 1} model.characters),
               Cmd.none
            )
         else
            (
               (Model.reset {model | controlled_team = 0} model.characters),
               Cmd.none
            )

      (Event.ServerReplied _) ->
         (
            (Model.invalidate
               model
               (Error.new Error.Unimplemented "Handle server reply.")
            ),
            Cmd.none
         )
