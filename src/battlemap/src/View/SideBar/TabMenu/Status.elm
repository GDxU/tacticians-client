module View.SideBar.TabMenu.Status exposing (get_html)

-- Elm -------------------------------------------------------------------------
import Dict

import Html
import Html.Attributes

-- Struct.Battlemap -------------------------------------------------------------------
import Struct.Battlemap
import Struct.Character
import Struct.Error
import Struct.Event
import Struct.Location
import Struct.Model
import Struct.Tile
import Struct.UI

import Util.Html

--------------------------------------------------------------------------------
-- LOCAL -----------------------------------------------------------------------
--------------------------------------------------------------------------------

get_char_info_html : (
      Struct.Model.Type ->
      Struct.Character.Ref ->
      (Html.Html Struct.Event.Type)
   )
get_char_info_html model char_ref =
   case (Dict.get char_ref model.characters) of
      Nothing -> (Html.text "Error: Unknown character selected.")
      (Just char) ->
         (Html.text
            (
               "Focusing "
               ++ char.name
               ++ " (Team "
               ++ (toString (Struct.Character.get_team char))
               ++ "): "
               ++ (toString (Struct.Character.get_movement_points char))
               ++ " movement points; "
               ++ (toString (Struct.Character.get_attack_range char))
               ++ " attack range. Health: "
               ++ (toString (Struct.Character.get_current_health char))
               ++ "/"
               ++ (toString (Struct.Character.get_max_health char))
            )
         )

get_char_attack_info_html : (
      Struct.Model.Type ->
      Struct.Character.Ref ->
      (Html.Html Struct.Event.Type)
   )
get_char_attack_info_html model char_ref =
   case (Dict.get char_ref model.characters) of
      Nothing -> (Html.text "Error: Unknown character selected.")
      (Just char) ->
         (Html.text
            (
               "Attacking "
               ++ char.name
               ++ " (Team "
               ++ (toString (Struct.Character.get_team char))
               ++ "): "
               ++ (toString (Struct.Character.get_movement_points char))
               ++ " movement points; "
               ++ (toString (Struct.Character.get_attack_range char))
               ++ " attack range. Health: "
               ++ (toString (Struct.Character.get_current_health char))
               ++ "/"
               ++ (toString (Struct.Character.get_max_health char))
            )
         )

get_error_html : Struct.Error.Type -> (Html.Html Struct.Event.Type)
get_error_html err =
   (Html.div
      [
         (Html.Attributes.class "battlemap-tabmenu-error-message")
      ]
      [
         (Html.text (Struct.Error.to_string err))
      ]
   )

get_tile_info_html : (
      Struct.Model.Type ->
      Struct.Location.Type ->
      (Html.Html Struct.Event.Type)
   )
get_tile_info_html model loc =
   case (Struct.Battlemap.try_getting_tile_at model.battlemap loc) of
      (Just tile) ->
         (Html.div
            [
               (Html.Attributes.class
                  "battlemap-tabmenu-tile-info-tab"
               )
            ]
            [
               (Html.div
                  [
                     (Html.Attributes.class "battlemap-tile-icon"),
                     (Html.Attributes.class "battlemap-tiled"),
                     (Html.Attributes.class
                        (
                           "asset-tile-"
                           ++
                           (Struct.Tile.get_icon_id tile)
                        )
                     )
                  ]
                  [
                  ]
               ),
               (Html.div
                  [
                  ]
                  [
                     (Html.text
                        (
                           "Focusing tile ("
                           ++ (toString loc.x)
                           ++ ", "
                           ++ (toString loc.y)
                           ++ "). {ID = "
                           ++ (Struct.Tile.get_icon_id tile)
                           ++ ", cost = "
                           ++ (toString (Struct.Tile.get_cost tile))
                           ++ "}."
                        )
                     )
                  ]
               )
            ]
         )

      Nothing -> (Html.text "Error: Unknown tile location selected.")

--------------------------------------------------------------------------------
-- EXPORTED --------------------------------------------------------------------
--------------------------------------------------------------------------------
get_html : Struct.Model.Type -> (Html.Html Struct.Event.Type)
get_html model =
   (Html.div
      [
         (Html.Attributes.class "battlemap-footer-tabmenu-content"),
         (Html.Attributes.class "battlemap-footer-tabmenu-content-status")
      ]
      (case model.state of
         (Struct.Model.InspectingTile tile_loc) ->
            [(get_tile_info_html model (Struct.Location.from_ref tile_loc))]

         (Struct.Model.InspectingCharacter char_ref) ->
            [(get_char_info_html model char_ref)]

         _ ->
            [
               (case (Struct.UI.get_previous_action model.ui) of
                  (Just (Struct.UI.SelectedLocation loc)) ->
                     (get_tile_info_html
                        model
                        (Struct.Location.from_ref loc)
                     )

                  (Just (Struct.UI.SelectedCharacter target_char)) ->
                     (get_char_info_html model target_char)

                  _ ->
                     (Html.text "Double-click on a character to control it.")
               )
            ]
      )
   )