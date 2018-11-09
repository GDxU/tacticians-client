module Comm.AddChar exposing (decode)

-- Elm -------------------------------------------------------------------------
import Json.Decode

-- Roster Editor ---------------------------------------------------------------
import Struct.CharacterRecord
import Struct.ServerReply

--------------------------------------------------------------------------------
-- TYPES -----------------------------------------------------------------------
--------------------------------------------------------------------------------

--------------------------------------------------------------------------------
-- LOCAL -----------------------------------------------------------------------
--------------------------------------------------------------------------------

internal_decoder : Struct.CharacterRecord.Type -> Struct.ServerReply.Type
internal_decoder char= (Struct.ServerReply.AddCharacter char)

--------------------------------------------------------------------------------
-- EXPORTED --------------------------------------------------------------------
--------------------------------------------------------------------------------
decode : (Json.Decode.Decoder Struct.ServerReply.Type)
decode = (Json.Decode.map (internal_decoder) (Struct.CharacterRecord.decoder))
