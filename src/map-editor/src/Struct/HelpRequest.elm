module Struct.HelpRequest exposing (Type(..))

-- Elm -------------------------------------------------------------------------

-- Battlemap -------------------------------------------------------------------
import Struct.Toolbox

--------------------------------------------------------------------------------
-- TYPES -----------------------------------------------------------------------
--------------------------------------------------------------------------------
type Type =
   None
   | HelpOnTool Struct.Toolbox.Tool
