module Comm.AddGlyphBoard exposing (decode)

-- Elm -------------------------------------------------------------------------
import Json.Decode

-- Roster Editor ---------------------------------------------------------------
import Struct.GlyphBoard
import Struct.ServerReply

--------------------------------------------------------------------------------
-- TYPES -----------------------------------------------------------------------
--------------------------------------------------------------------------------

--------------------------------------------------------------------------------
-- LOCAL -----------------------------------------------------------------------
--------------------------------------------------------------------------------
internal_decoder : Struct.GlyphBoard.Type -> Struct.ServerReply.Type
internal_decoder glb = (Struct.ServerReply.AddGlyphBoard glb)

--------------------------------------------------------------------------------
-- EXPORTED --------------------------------------------------------------------
--------------------------------------------------------------------------------
decode : (Json.Decode.Decoder Struct.ServerReply.Type)
decode = (Json.Decode.map (internal_decoder) (Struct.GlyphBoard.decoder))
