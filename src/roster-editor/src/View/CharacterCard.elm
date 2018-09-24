module View.CharacterCard exposing
   (
      get_minimal_html,
      get_full_html
   )

-- Elm -------------------------------------------------------------------------
import List

import Html
import Html.Attributes
import Html.Events

-- Battle ----------------------------------------------------------------------
import Struct.Armor
import Struct.Character
import Struct.Event
import Struct.HelpRequest
import Struct.Omnimods
import Struct.Statistics
import Struct.Weapon
import Struct.WeaponSet

import Util.Html

import View.Character
import View.Gauge

--------------------------------------------------------------------------------
-- LOCAL -----------------------------------------------------------------------
--------------------------------------------------------------------------------
get_name : (
      Struct.Character.Type ->
      (Html.Html Struct.Event.Type)
   )
get_name char =
   (Html.div
      [
         (Html.Attributes.class "roster-info-card-name"),
         (Html.Attributes.class "roster-info-card-text-field"),
         (Html.Attributes.class "roster-character-card-name")
      ]
      [
         (Html.text (Struct.Character.get_name char))
      ]
   )

get_health_bar : (
      Struct.Character.Type ->
      (Html.Html Struct.Event.Type)
   )
get_health_bar char =
   let
      max =
         (Struct.Statistics.get_max_health
            (Struct.Character.get_statistics char)
         )
   in
      (View.Gauge.get_html
         ("HP: " ++ (toString max))
         100.0
         [(Html.Attributes.class "roster-character-card-health")]
         []
         []
      )

get_statuses : (
      Struct.Character.Type ->
      (Html.Html Struct.Event.Type)
   )
get_statuses char =
   (Html.div
      [
         (Html.Attributes.class "roster-character-card-statuses")
      ]
      [
      ]
   )

get_movement_bar : Struct.Character.Type -> (Html.Html Struct.Event.Type)
get_movement_bar char =
   let
      max =
         (Struct.Statistics.get_movement_points
            (Struct.Character.get_statistics char)
         )
   in
      (View.Gauge.get_html
         (
            "MP: "
            ++
            (toString
               (Struct.Statistics.get_movement_points
                  (Struct.Character.get_statistics char)
               )
            )
         )
         100.0
         [(Html.Attributes.class "roster-character-card-movement")]
         []
         []
      )

get_weapon_field_header : (
      Float ->
      Struct.Weapon.Type ->
      (Html.Html Struct.Event.Type)
   )
get_weapon_field_header damage_multiplier weapon =
   (Html.div
      [
         (Html.Attributes.class "roster-character-card-header")
      ]
      [
         (Html.div
            [
            ]
            [
               (Html.text (Struct.Weapon.get_name weapon))
            ]
         ),
         (Html.div
            [
            ]
            [
               (Html.text
                  (
                     "~"
                     ++
                     (toString
                        (ceiling
                           (
                              (toFloat (Struct.Weapon.get_damage_sum weapon))
                              * damage_multiplier
                           )
                        )
                     )
                     ++ " dmg @ ["
                     ++ (toString (Struct.Weapon.get_defense_range weapon))
                     ++ ", "
                     ++ (toString (Struct.Weapon.get_attack_range weapon))
                     ++ "]"
                  )
               )
            ]
         )
      ]
   )

get_mod_html : (String, Int) -> (Html.Html Struct.Event.Type)
get_mod_html mod =
   let
      (category, value) = mod
   in
      (Html.div
         [
            (Html.Attributes.class "roster-info-card-mod")
         ]
         [
            (Html.text
               (category ++ ": " ++ (toString value))
            )
         ]
      )

get_multiplied_mod_html : Float -> (String, Int) -> (Html.Html Struct.Event.Type)
get_multiplied_mod_html multiplier mod =
   let
      (category, value) = mod
   in
      (Html.div
         [
            (Html.Attributes.class "roster-character-card-mod")
         ]
         [
            (Html.text
               (
                  category
                  ++ ": "
                  ++ (toString (ceiling ((toFloat value) * multiplier)))
               )
            )
         ]
      )

get_weapon_details : (
      Struct.Omnimods.Type ->
      Float ->
      Struct.Weapon.Type ->
      (Html.Html Struct.Event.Type)
   )
get_weapon_details omnimods damage_multiplier weapon =
   (Html.div
      [
         (Html.Attributes.class "roster-character-card-weapon")
      ]
      [
         (get_weapon_field_header damage_multiplier weapon),
         (Html.div
            [
               (Html.Attributes.class "roster-info-card-omnimods-listing")
            ]
            (List.map
               (get_multiplied_mod_html damage_multiplier)
               (Struct.Omnimods.get_attack_mods omnimods)
            )
         )
      ]
   )

get_weapon_summary : (
      Float ->
      Struct.Weapon.Type ->
      (Html.Html Struct.Event.Type)
   )
get_weapon_summary damage_multiplier weapon =
   (Html.div
      [
         (Html.Attributes.class "roster-character-card-weapon-summary")
      ]
      [
         (get_weapon_field_header damage_multiplier weapon)
      ]
   )

get_armor_details : (
      Struct.Omnimods.Type ->
      Struct.Armor.Type ->
      (Html.Html Struct.Event.Type)
   )
get_armor_details omnimods armor =
   (Html.div
      [
         (Html.Attributes.class "roster-character-card-armor")
      ]
      [
         (Html.div
            [
               (Html.Attributes.class "roster-character-card-armor-name")
            ]
            [
               (Html.text (Struct.Armor.get_name armor))
            ]
         ),
         (Html.div
            [
               (Html.Attributes.class "roster-info-card-omnimods-listing")
            ]
            (List.map
               (get_mod_html)
               (Struct.Omnimods.get_defense_mods omnimods)
            )
         )
      ]
   )

stat_name  : String -> (Html.Html Struct.Event.Type)
stat_name name =
   (Html.div
      [
         (Html.Attributes.class "roster-character-card-stat-name")
      ]
      [
         (Html.text name)
      ]
   )

stat_val : Int -> Bool -> (Html.Html Struct.Event.Type)
stat_val val perc =
   (Html.div
      [
         (Html.Attributes.class "roster-character-card-stat-val")
      ]
      [
         (Html.text
            (
               (toString val)
               ++
               (
                  if perc
                  then
                     "%"
                  else
                     ""
               )
            )
         )
      ]
   )

get_relevant_stats : (
      Struct.Statistics.Type ->
      (Html.Html Struct.Event.Type)
   )
get_relevant_stats stats =
   (Html.div
      [
         (Html.Attributes.class "roster-character-card-stats")
      ]
      [
         (stat_name "Dodge"),
         (stat_val (Struct.Statistics.get_dodges stats) True),
         (stat_name "Parry"),
         (stat_val (Struct.Statistics.get_parries stats) True),
         (stat_name "Accu."),
         (stat_val (Struct.Statistics.get_accuracy stats) False),
         (stat_name "2xHit"),
         (stat_val (Struct.Statistics.get_double_hits stats) True),
         (stat_name "Crit."),
         (stat_val (Struct.Statistics.get_critical_hits stats) True)
      ]
   )

--------------------------------------------------------------------------------
-- EXPORTED --------------------------------------------------------------------
--------------------------------------------------------------------------------
get_minimal_html : Struct.Character.Type -> (Html.Html Struct.Event.Type)
get_minimal_html char =
   (Html.div
      [
         (Html.Attributes.class "roster-info-card"),
         (Html.Attributes.class "roster-info-card-minimal"),
         (Html.Attributes.class "roster-character-card"),
         (Html.Attributes.class "roster-character-card-minimal")
      ]
      [
         (get_name char),
         (Html.div
            [
               (Html.Attributes.class "roster-info-card-top"),
               (Html.Attributes.class "roster-character-card-top")
            ]
            [
               (Html.div
                  [
                     (Html.Attributes.class "roster-info-card-picture")
                  ]
                  [
                     (View.Character.get_portrait_html char)
                  ]
               ),
               (get_health_bar char),
               (get_movement_bar char),
               (get_statuses char)
            ]
         )
      ]
   )

get_full_html : Struct.Character.Type -> (Html.Html Struct.Event.Type)
get_full_html char =
   let
      weapon_set = (Struct.Character.get_weapons char)
      main_weapon = (Struct.WeaponSet.get_active_weapon weapon_set)
      char_statistics = (Struct.Character.get_statistics char)
      damage_modifier = (Struct.Statistics.get_damage_modifier char_statistics)
      secondary_weapon = (Struct.WeaponSet.get_secondary_weapon weapon_set)
      armor = (Struct.Character.get_armor char)
      omnimods = (Struct.Character.get_current_omnimods char)
   in
      (Html.div
         [
            (Html.Attributes.class "roster-info-card"),
            (Html.Attributes.class "roster-character-card")
         ]
         [
            (get_name char),
            (Html.div
               [
                  (Html.Attributes.class "roster-info-card-top"),
                  (Html.Attributes.class "roster-character-card-top")
               ]
               [
                  (Html.div
                     [
                        (Html.Attributes.class "roster-info-card-picture")
                     ]
                     [
                        (View.Character.get_portrait_html char)
                     ]
                  ),
                  (get_health_bar char),
                  (get_movement_bar char),
                  (get_statuses char)
               ]
            ),
            (get_weapon_details omnimods damage_modifier main_weapon),
            (get_armor_details omnimods armor),
            (get_relevant_stats char_statistics),
            (get_weapon_summary damage_modifier secondary_weapon)
         ]
      )