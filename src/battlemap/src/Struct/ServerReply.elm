module Struct.ServerReply exposing (Type(..))

-- Elm -------------------------------------------------------------------------

-- Battlemap -------------------------------------------------------------------
import Struct.Armor
import Struct.Battlemap
import Struct.Character
import Struct.TurnResult
import Struct.Weapon

--------------------------------------------------------------------------------
-- TYPES -----------------------------------------------------------------------
--------------------------------------------------------------------------------

type Type =
   Okay
   | AddArmor Struct.Armor.Type
   | AddWeapon Struct.Weapon.Type
   | AddCharacter Struct.Character.Type
   | SetMap Struct.Battlemap.Type
   | TurnResults (List Struct.TurnResult.Type)
   | SetTimeline (List Struct.TurnResult.Type)

--------------------------------------------------------------------------------
-- LOCAL -----------------------------------------------------------------------
--------------------------------------------------------------------------------

--------------------------------------------------------------------------------
-- EXPORTED --------------------------------------------------------------------
--------------------------------------------------------------------------------
