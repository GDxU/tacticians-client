module Struct.ServerReply exposing (Type(..))

-- Elm -------------------------------------------------------------------------

-- Battle ----------------------------------------------------------------------
import Struct.Armor
import Struct.Portrait
import Struct.Player
import Struct.Map
import Struct.Character
import Struct.Tile
import Struct.TurnResult
import Struct.Weapon

--------------------------------------------------------------------------------
-- TYPES -----------------------------------------------------------------------
--------------------------------------------------------------------------------

type Type =
   Okay
   | Disconnected
   | AddArmor Struct.Armor.Type
   | AddPortrait Struct.Portrait.Type
   | AddPlayer Struct.Player.Type
   | AddWeapon Struct.Weapon.Type
   | AddCharacter Struct.Character.TypeAndEquipmentRef
   | AddTile Struct.Tile.Type
   | SetMap Struct.Map.Type
   | TurnResults (List Struct.TurnResult.Type)
   | SetTimeline (List Struct.TurnResult.Type)

--------------------------------------------------------------------------------
-- LOCAL -----------------------------------------------------------------------
--------------------------------------------------------------------------------

--------------------------------------------------------------------------------
-- EXPORTED --------------------------------------------------------------------
--------------------------------------------------------------------------------
