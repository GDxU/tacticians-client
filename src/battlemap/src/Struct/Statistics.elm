module Struct.Statistics exposing
   (
      Type,
      get_movement_points,
      get_max_health,
      get_dodges,
      get_parries,
      get_damage_min,
      get_damage_max,
      get_accuracy,
      get_double_hits,
      get_critical_hits,
      new
   )

-- Elm -------------------------------------------------------------------------
import List

-- Battlemap -------------------------------------------------------------------
import Struct.Attributes
import Struct.Weapon
import Struct.WeaponSet

--------------------------------------------------------------------------------
-- TYPES -----------------------------------------------------------------------
--------------------------------------------------------------------------------
type alias Type =
   {
      movement_points : Int,
      max_health : Int,
      dodges : Int,
      parries : Int,
      damage_min : Int,
      damage_max : Int,
      accuracy : Int,
      double_hits : Int,
      critical_hits : Int
   }

--------------------------------------------------------------------------------
-- LOCAL -----------------------------------------------------------------------
--------------------------------------------------------------------------------
average : (List Int) -> Float
average l = ((toFloat (List.sum l)) / (toFloat (List.length l)))

float_to_int : Float -> Int
float_to_int f =
   (ceiling f)

gentle_squared_growth : Int -> Int
gentle_squared_growth v = (float_to_int (((toFloat v)^1.8)/20.0))

sudden_squared_growth : Int -> Int
sudden_squared_growth v = (float_to_int (((toFloat v)^2.5)/1000.0))

sudden_exp_growth : Int -> Int
sudden_exp_growth v = (float_to_int (4.0^((toFloat v)/25.0)))

sudden_exp_growth_f : Float -> Int
sudden_exp_growth_f f = (float_to_int (4.0^(f/25.0)))

already_high_slow_growth : Int -> Int
already_high_slow_growth v =
   (float_to_int
      (30.0 * (logBase 10.0 (((toFloat v) + 5.0)/4.0)))
   )

-- FIXME: Bad scaling.
damage_base_mod : Float -> Float
damage_base_mod str = ((str - 50.0)/75.0)

apply_damage_base_mod : Float -> Float -> Int
apply_damage_base_mod bmod dmg =
   (max 0 (float_to_int (dmg + (bmod * dmg))))

--------------------------------------------------------------------------------
-- EXPORTED --------------------------------------------------------------------
--------------------------------------------------------------------------------
get_movement_points : Type -> Int
get_movement_points t = t.movement_points

get_max_health : Type -> Int
get_max_health t = t.max_health

get_dodges : Type -> Int
get_dodges t = t.dodges

get_parries : Type -> Int
get_parries t = t.parries

get_damage_min : Type -> Int
get_damage_min t = t.damage_min

get_damage_max : Type -> Int
get_damage_max t = t.damage_max

get_accuracy : Type -> Int
get_accuracy t = t.accuracy

get_double_hits : Type -> Int
get_double_hits t = t.double_hits

get_critical_hits : Type -> Int
get_critical_hits t = t.critical_hits

new : (
      Struct.Attributes.Type ->
      Struct.WeaponSet.Type ->
      Type
   )
new att wp_set =
   let
      active_weapon = (Struct.WeaponSet.get_active_weapon wp_set)
      dmg_bmod =
         (damage_base_mod (toFloat (Struct.Attributes.get_strength att)))
   in
      {
         movement_points =
            (gentle_squared_growth (Struct.Attributes.get_speed att)),
         max_health =
            (gentle_squared_growth (Struct.Attributes.get_constitution att)),
         dodges =
            (clamp
               5
               75
               (sudden_exp_growth_f
                  (average
                     [
                        (Struct.Attributes.get_dexterity att),
                        (Struct.Attributes.get_mind att),
                        (Struct.Attributes.get_speed att)
                     ]
                  )
               )
            ),
         parries =
            (clamp
               0
               75
               (sudden_exp_growth_f
                  (average
                     [
                        (Struct.Attributes.get_dexterity att),
                        (Struct.Attributes.get_speed att),
                        (Struct.Attributes.get_strength att)
                     ]
                  )
               )
            ),
         damage_min =
            (apply_damage_base_mod
               dmg_bmod
               (toFloat (Struct.Weapon.get_min_damage active_weapon))
            ),
         damage_max =
            (apply_damage_base_mod
               dmg_bmod
               (toFloat (Struct.Weapon.get_max_damage active_weapon))
            ),
         accuracy =
            (already_high_slow_growth (Struct.Attributes.get_dexterity att)),
         double_hits =
            (clamp
               0
               100
               (sudden_squared_growth (Struct.Attributes.get_speed att))
            ),
         critical_hits =
            (clamp
               0
               100
               (sudden_squared_growth (Struct.Attributes.get_intelligence att))
            )
   }
