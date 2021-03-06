module Struct.Omnimods exposing
   (
      Type,
      new,
      merge,
      none,
      apply_to_attributes,
      apply_to_statistics,
      get_attack_damage,
      get_damage_sum,
      get_attributes_mods,
      get_statistics_mods,
      get_attack_mods,
      get_defense_mods,
      get_all_mods,
      scale,
      decoder
   )

-- Elm -------------------------------------------------------------------------
import Dict

import Json.Decode
import Json.Decode.Pipeline

-- Map -------------------------------------------------------------------
import Struct.Attributes
import Struct.Statistics
import Struct.DamageType

--------------------------------------------------------------------------------
-- TYPES -----------------------------------------------------------------------
--------------------------------------------------------------------------------
type alias Type =
   {
      attributes : (Dict.Dict String Int),
      statistics : (Dict.Dict String Int),
      attack : (Dict.Dict String Int),
      defense : (Dict.Dict String Int)
   }

type alias GenericMod =
   {
      t : String,
      v : Int
   }
--------------------------------------------------------------------------------
-- LOCAL -----------------------------------------------------------------------
--------------------------------------------------------------------------------
generic_mods_decoder : (Json.Decode.Decoder (Dict.Dict String Int))
generic_mods_decoder =
   (Json.Decode.map
      ((Dict.fromList) >> (Dict.remove "none"))
      (Json.Decode.list
         (Json.Decode.map
            (\gm -> (gm.t, gm.v))
            (Json.Decode.succeed
               GenericMod
               |> (Json.Decode.Pipeline.required "t" Json.Decode.string)
               |> (Json.Decode.Pipeline.required "v" Json.Decode.int)
            )
         )
      )
   )

merge_mods : (
      (Dict.Dict String Int) ->
      (Dict.Dict String Int) ->
      (Dict.Dict String Int)
   )
merge_mods a_mods b_mods =
   (Dict.merge
      (Dict.insert)
      (\t -> \v_a  -> \v_b -> \r -> (Dict.insert t (v_a + v_b) r))
      (Dict.insert)
      a_mods
      b_mods
      (Dict.empty)
   )

scale_dict_value : Float -> String -> Int -> Int
scale_dict_value modifier entry_name value =
   (ceiling ((toFloat value) * modifier))
--------------------------------------------------------------------------------
-- EXPORTED --------------------------------------------------------------------
--------------------------------------------------------------------------------
decoder : (Json.Decode.Decoder Type)
decoder =
   (Json.Decode.succeed
      Type
      |> (Json.Decode.Pipeline.required "attm" generic_mods_decoder)
      |> (Json.Decode.Pipeline.required "stam" generic_mods_decoder)
      |> (Json.Decode.Pipeline.required "atkm" generic_mods_decoder)
      |> (Json.Decode.Pipeline.required "defm" generic_mods_decoder)
   )

new : (
      (List (String, Int)) ->
      (List (String, Int)) ->
      (List (String, Int)) ->
      (List (String, Int)) ->
      Type
   )
new attribute_mods statistic_mods attack_mods defense_mods =
   {
      attributes = (Dict.fromList attribute_mods),
      statistics = (Dict.fromList statistic_mods),
      attack = (Dict.fromList attack_mods),
      defense = (Dict.fromList defense_mods)
   }

none : Type
none =
   {
      attributes = (Dict.empty),
      statistics = (Dict.empty),
      attack = (Dict.empty),
      defense = (Dict.empty)
   }

merge : Type -> Type -> Type
merge omni_a omni_b =
   {
      attributes = (merge_mods omni_a.attributes omni_b.attributes),
      statistics = (merge_mods omni_a.statistics omni_b.statistics),
      attack = (merge_mods omni_a.attack omni_b.attack),
      defense = (merge_mods omni_a.defense omni_b.defense)
   }

apply_to_attributes : Type -> Struct.Attributes.Type -> Struct.Attributes.Type
apply_to_attributes omnimods attributes =
   (Dict.foldl
      ((Struct.Attributes.decode_category) >> (Struct.Attributes.mod))
      attributes
      omnimods.attributes
   )

apply_to_statistics : Type -> Struct.Statistics.Type -> Struct.Statistics.Type
apply_to_statistics omnimods statistics =
   (Dict.foldl
      ((Struct.Statistics.decode_category) >> (Struct.Statistics.mod))
      statistics
      omnimods.statistics
   )

get_damage_sum : Type -> Int
get_damage_sum omni =
   (Dict.foldl (\t -> \v -> \result -> (result + v)) 0 omni.attack)

get_attack_damage : Float -> Type -> Type -> Int
get_attack_damage dmg_modifier atk_omni def_omni =
   let
      base_def =
         (
            case
               (Dict.get
                  (Struct.DamageType.encode Struct.DamageType.Base)
                  def_omni.defense
               )
            of
               (Just v) -> v
               Nothing -> 0
         )
   in
      (Dict.foldl
         (\t -> \v -> \result ->
            let
               actual_atk =
                  (max
                     0
                     (
                        (ceiling ((toFloat v) * dmg_modifier))
                        - base_def
                     )
                  )
            in
               case (Dict.get t def_omni.defense) of
                  (Just def_v) -> (result + (max 0 (actual_atk - def_v)))
                  Nothing -> (result + actual_atk)
         )
         0
         atk_omni.attack
      )

scale : Float -> Type -> Type
scale multiplier omnimods =
   {omnimods |
      attributes = (Dict.map (scale_dict_value multiplier) omnimods.attributes),
      statistics = (Dict.map (scale_dict_value multiplier) omnimods.statistics),
      attack = (Dict.map (scale_dict_value multiplier) omnimods.attack),
      defense =
         (Dict.map (scale_dict_value multiplier) omnimods.defense)
   }

get_attributes_mods : Type -> (List (String, Int))
get_attributes_mods omnimods = (Dict.toList omnimods.attributes)

get_statistics_mods : Type -> (List (String, Int))
get_statistics_mods omnimods = (Dict.toList omnimods.statistics)

get_attack_mods : Type -> (List (String, Int))
get_attack_mods omnimods = (Dict.toList omnimods.attack)

get_defense_mods : Type -> (List (String, Int))
get_defense_mods omnimods = (Dict.toList omnimods.defense)

get_all_mods : Type -> (List (String, Int))
get_all_mods omnimods =
   (
      (get_attributes_mods omnimods)
      ++ (get_statistics_mods omnimods)
      ++ (get_attack_mods omnimods)
      ++ (get_defense_mods omnimods)
   )
