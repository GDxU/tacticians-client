module Struct.Tile exposing
   (
      Ref,
      Type,
      Instance,
      Border,
      new,
      clone_instance,
      new_instance,
      new_border,
      error_tile_instance,
      get_id,
      get_name,
      set_borders,
      get_borders,
      get_border_type_id,
      get_border_variant_ix,
      get_cost,
      get_instance_cost,
      get_location,
      get_type_id,
      get_family,
      get_instance_family,
      get_variant_ix,
      get_local_variant_ix,
      solve_tile_instance,
      decoder
   )

-- Elm -------------------------------------------------------------------------
import Dict

import Json.Decode
import Json.Decode.Pipeline

-- Battlemap -------------------------------------------------------------------
import Constants.UI
import Constants.Movement

import Struct.Location

--------------------------------------------------------------------------------
-- TYPES -----------------------------------------------------------------------
--------------------------------------------------------------------------------
type alias Ref = Int

type alias PartiallyDecoded =
   {
      id : Int,
      nam : String,
      ct : Int,
      fa : Int,
      de : Int
   }

type alias Type =
   {
      id : Int,
      name : String,
      crossing_cost : Int,
      family : Int,
      depth : Int
   }

type alias Border =
   {
      type_id : Int,
      variant_ix : Int
   }

type alias Instance =
   {
      location : Struct.Location.Type,
      crossing_cost : Int,
      family : Int,
      type_id : Int,
      variant_ix : Int,
      borders : (List Border)
   }

--------------------------------------------------------------------------------
-- LOCAL -----------------------------------------------------------------------
--------------------------------------------------------------------------------
noise_function : Int -> Int -> Int -> Int
noise_function a b c =
   let
      af = (toFloat a)
      bf = (toFloat b)
      cf = (toFloat c)
      (df, ef) = (toPolar (af, bf))
      (ff, gf) = (toPolar (bf, af))
      (hf, jf) = (toPolar (bf, cf))
      (kf, lf) = (toPolar (cf, bf))
      (mf, nf) = (toPolar (af, cf))
      (qf, rf) = (toPolar (cf, af))
      (resA, resB) = (fromPolar ((df + qf), (ef + nf)))
      (resC, resD) = (fromPolar ((hf + mf), (jf + gf)))
      (resE, resF) = (toPolar ((resA - resC), (resB - resD)))
   in
      (round (resE - resF))

finish_decoding : PartiallyDecoded -> Type
finish_decoding add_tile =
   {
      id = add_tile.id,
      name = add_tile.nam,
      crossing_cost = add_tile.ct,
      family = add_tile.fa,
      depth = add_tile.de
   }

--------------------------------------------------------------------------------
-- EXPORTED --------------------------------------------------------------------
--------------------------------------------------------------------------------
new : Int -> String -> Int -> Int -> Int -> Type
new id name crossing_cost family depth =
   {
      id = id,
      name = name,
      crossing_cost = crossing_cost,
      family = family,
      depth = depth
   }

clone_instance : Struct.Location.Type -> Instance -> Instance
clone_instance loc inst = {inst | location = loc}

new_border : Int -> Int -> Border
new_border type_id variant_ix =
   {
      type_id = type_id,
      variant_ix = variant_ix
   }

new_instance : (
      Struct.Location.Type ->
      Int ->
      Int ->
      Int ->
      Int ->
      (List Border) ->
      Instance
   )
new_instance location type_id variant_ix crossing_cost family borders =
   {
      location = location,
      type_id = type_id,
      variant_ix = variant_ix,
      crossing_cost = crossing_cost,
      family = family,
      borders = borders
   }

error_tile_instance : Int -> Int -> Instance
error_tile_instance x y =
   {
      location = {x = x, y = y},
      type_id = 0,
      variant_ix = 0,
      family = 0,
      crossing_cost = Constants.Movement.cost_when_out_of_bounds,
      borders = []
   }

get_id : Type -> Int
get_id tile = tile.id

get_cost : Type -> Int
get_cost tile = tile.crossing_cost

get_instance_cost : Instance -> Int
get_instance_cost tile_inst = tile_inst.crossing_cost

get_name : Type -> String
get_name tile = tile.name

get_location : Instance -> Struct.Location.Type
get_location tile_inst = tile_inst.location

get_type_id : Instance -> Int
get_type_id tile_inst = tile_inst.type_id

get_border_type_id : Border -> Int
get_border_type_id tile_border = tile_border.type_id

get_family : Type -> Int
get_family tile = tile.family

set_borders : (List Border) -> Instance -> Instance
set_borders borders tile_inst = {tile_inst | borders = borders}

get_borders : Instance -> (List Border)
get_borders tile_inst = tile_inst.borders

get_instance_family : Instance -> Int
get_instance_family tile_inst = tile_inst.family

get_variant_ix : Instance -> Int
get_variant_ix tile_inst = tile_inst.variant_ix

get_border_variant_ix : Border -> Int
get_border_variant_ix tile_border = tile_border.variant_ix

get_local_variant_ix : Instance -> Int
get_local_variant_ix tile_inst =
   (
      (noise_function
         tile_inst.location.x
         tile_inst.location.y
         tile_inst.crossing_cost
      )
      % Constants.UI.local_variants_per_tile
   )

solve_tile_instance : (Dict.Dict Int Type) -> Instance -> Instance
solve_tile_instance tiles tile_instance =
   case (Dict.get tile_instance.type_id tiles) of
      (Just tile) ->
         {tile_instance |
            crossing_cost = tile.crossing_cost,
            family = tile.family
         }

      Nothing ->
         {tile_instance |
            crossing_cost = -1,
            family = -1
         }

decoder : (Json.Decode.Decoder Type)
decoder =
   (Json.Decode.map
      (finish_decoding)
      (Json.Decode.Pipeline.decode
         PartiallyDecoded
         |> (Json.Decode.Pipeline.required "id" Json.Decode.int)
         |> (Json.Decode.Pipeline.required "nam" Json.Decode.string)
         |> (Json.Decode.Pipeline.required "ct" Json.Decode.int)
         |> (Json.Decode.Pipeline.required "fa" Json.Decode.int)
         |> (Json.Decode.Pipeline.required "de" Json.Decode.int)
      )
   )
