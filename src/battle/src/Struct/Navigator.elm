module Struct.Navigator exposing
   (
      Type,
      Summary,
      new,
      get_current_location,
      get_starting_location,
      get_remaining_points,
      get_range_markers,
      get_path,
      get_summary,
      clear_path,
      lock_path,
      unlock_path,
      lock_path_with_new_attack_ranges,
      try_adding_step,
      try_getting_path_to
   )

-- Elm -------------------------------------------------------------------------
import Dict

-- Battle ----------------------------------------------------------------------
import Struct.Location
import Struct.Direction
import Struct.Marker
import Struct.Path
import Struct.RangeIndicator

--------------------------------------------------------------------------------
-- TYPES -----------------------------------------------------------------------
--------------------------------------------------------------------------------
type alias Type =
   {
      starting_location: Struct.Location.Type,
      movement_dist: Int,
      defense_dist: Int,
      attack_dist: Int,
      path: Struct.Path.Type,
      locked_path: Bool,
      range_indicators:
         (Dict.Dict
            Struct.Location.Ref
            Struct.RangeIndicator.Type
         ),
      cost_fun: (Struct.Location.Type -> Int)
   }

type alias Summary =
   {
      starting_location: Struct.Location.Type,
      path: (List Struct.Direction.Type),
      markers: (List (Struct.Location.Ref, Struct.Marker.Type)),
      locked_path: Bool
   }

--------------------------------------------------------------------------------
-- LOCAL -----------------------------------------------------------------------
--------------------------------------------------------------------------------

--------------------------------------------------------------------------------
-- EXPORTED --------------------------------------------------------------------
--------------------------------------------------------------------------------
new : (
      Struct.Location.Type ->
      Int ->
      Int ->
      Int ->
      (Struct.Location.Type -> Int) ->
      Type
   )
new start_loc mov_dist def_dist atk_dist cost_fun =
   {
      starting_location = start_loc,
      movement_dist = mov_dist,
      attack_dist = atk_dist,
      defense_dist = def_dist,
      path = (Struct.Path.new start_loc mov_dist),
      locked_path = False,
      range_indicators =
         (Struct.RangeIndicator.generate
            start_loc
            mov_dist
            def_dist
            atk_dist
            (cost_fun)
         ),
      cost_fun = cost_fun
   }

get_current_location : Type -> Struct.Location.Type
get_current_location navigator =
   (Struct.Path.get_current_location navigator.path)

get_starting_location : Type -> Struct.Location.Type
get_starting_location navigator = navigator.starting_location

get_remaining_points : Type -> Int
get_remaining_points navigator =
    (Struct.Path.get_remaining_points navigator.path)

get_range_markers : (
      Type ->
      (List
         (Struct.Location.Ref, Struct.RangeIndicator.Type)
      )
   )
get_range_markers navigator = (Dict.toList navigator.range_indicators)

get_path : Type -> (List Struct.Direction.Type)
get_path navigator = (Struct.Path.get_summary navigator.path)

get_summary : Type -> Summary
get_summary navigator =
   {
      starting_location = navigator.starting_location,
      path = (Struct.Path.get_summary navigator.path),
      markers =
         (List.map
            (\(loc, range_indicator) ->
               (
                  loc,
                  (Struct.RangeIndicator.get_marker
                     range_indicator
                  )
               )
            )
            (Dict.toList
               navigator.range_indicators
            )
         ),
      locked_path = navigator.locked_path
   }

clear_path : Type -> Type
clear_path navigator =
   if (navigator.locked_path)
   then
      navigator
   else
      {navigator |
         path =
            (Struct.Path.new
               navigator.starting_location
               navigator.movement_dist
            )
      }

lock_path : Type -> Type
lock_path navigator =
   {navigator |
      range_indicators =
         (Struct.RangeIndicator.generate
            (Struct.Path.get_current_location navigator.path)
            0
            navigator.defense_dist
            navigator.attack_dist
            (navigator.cost_fun)
         ),
      locked_path = True
   }

unlock_path : Type -> Type
unlock_path navigator =
   {navigator |
      range_indicators =
         (Struct.RangeIndicator.generate
            navigator.starting_location
            navigator.movement_dist
            navigator.defense_dist
            navigator.attack_dist
            (navigator.cost_fun)
         ),
      locked_path = True
   }

lock_path_with_new_attack_ranges : Int -> Int -> Type -> Type
lock_path_with_new_attack_ranges range_min range_max navigator =
   {navigator |
      range_indicators =
         (Struct.RangeIndicator.generate
            (Struct.Path.get_current_location navigator.path)
            0
            range_min
            range_max
            (navigator.cost_fun)
         ),
      locked_path = True
   }

try_adding_step : (
      Struct.Direction.Type ->
      Type ->
      (Maybe Type)
   )
try_adding_step dir navigator =
   if (navigator.locked_path)
   then
      Nothing
   else
      case
         (Struct.Path.try_following_direction
            (navigator.cost_fun)
            (Just navigator.path)
            dir
         )
      of
         (Just path) -> (Just {navigator | path = path})
         Nothing -> Nothing

try_getting_path_to : (
      Struct.Location.Ref ->
      Type ->
      (Maybe (List Struct.Direction.Type))
   )
try_getting_path_to loc_ref navigator =
   case (Dict.get loc_ref navigator.range_indicators) of
      (Just target) ->
         (Just (Struct.RangeIndicator.get_path target))

      Nothing -> Nothing

