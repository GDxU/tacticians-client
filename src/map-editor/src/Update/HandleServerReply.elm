module Update.HandleServerReply exposing (apply_to)

-- Elm -------------------------------------------------------------------------
import Dict

import Http

-- Map -------------------------------------------------------------------
import Struct.Map
import Struct.Error
import Struct.Event
import Struct.Model
import Struct.ServerReply
import Struct.Tile
import Struct.TilePattern

--------------------------------------------------------------------------------
-- TYPES -----------------------------------------------------------------------
--------------------------------------------------------------------------------

--------------------------------------------------------------------------------
-- LOCAL -----------------------------------------------------------------------
--------------------------------------------------------------------------------
add_tile : (
      Struct.Tile.Type ->
      (Struct.Model.Type, (Maybe Struct.Error.Type)) ->
      (Struct.Model.Type, (Maybe Struct.Error.Type))
   )
add_tile tl current_state =
   case current_state of
      (_, (Just _)) -> current_state
      (model, _) -> ((Struct.Model.add_tile tl model), Nothing)

add_tile_pattern : (
      Struct.TilePattern.Type ->
      (Struct.Model.Type, (Maybe Struct.Error.Type)) ->
      (Struct.Model.Type, (Maybe Struct.Error.Type))
   )
add_tile_pattern tp current_state =
   case current_state of
      (_, (Just _)) -> current_state
      (model, _) ->
         (
            (Struct.Model.add_tile_pattern tp model),
            Nothing
         )

set_map : (
      Struct.Map.Type ->
      (Struct.Model.Type, (Maybe Struct.Error.Type)) ->
      (Struct.Model.Type, (Maybe Struct.Error.Type))
   )
set_map map current_state =
   case current_state of
      (_, (Just _)) -> current_state
      (model, _) ->
         ( {model | map = (Struct.Map.solve_tiles model.tiles map)}, Nothing)

refresh_map : (
      (Struct.Model.Type, (Maybe Struct.Error.Type)) ->
      (Struct.Model.Type, (Maybe Struct.Error.Type))
   )
refresh_map current_state =
   case current_state of
      (_, (Just _)) -> current_state
      (model, _) ->
         (
            {model | map = (Struct.Map.solve_tiles model.tiles model.map)},
            Nothing
         )

apply_command : (
      Struct.ServerReply.Type ->
      (Struct.Model.Type, (Maybe Struct.Error.Type)) ->
      (Struct.Model.Type, (Maybe Struct.Error.Type))
   )
apply_command command current_state =
   case command of
      (Struct.ServerReply.AddTile tl) ->
         (add_tile tl current_state)

      (Struct.ServerReply.AddTilePattern tp) ->
         (add_tile_pattern tp current_state)

      (Struct.ServerReply.SetMap map) ->
         (set_map map current_state)

      Struct.ServerReply.Okay ->
         (refresh_map current_state)

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
               (Struct.Error.new Struct.Error.Networking (toString error))
               model
            ),
            Cmd.none
         )

      (Result.Ok commands) ->
         case (List.foldl (apply_command) (model, Nothing) commands) of
            (updated_model, Nothing) -> (updated_model, Cmd.none)
            (_, (Just error)) ->
               (
                  (Struct.Model.invalidate error model),
                  Cmd.none
               )
