module Struct.Portrait exposing
   (
      Type,
      Ref,
      none,
      get_id,
      get_name,
      get_body_id,
      get_icon_id,
      decoder
   )

-- Elm -------------------------------------------------------------------------
import Json.Decode
import Json.Decode.Pipeline

-- Battle ----------------------------------------------------------------------

--------------------------------------------------------------------------------
-- TYPES -----------------------------------------------------------------------
--------------------------------------------------------------------------------
type alias Type =
   {
      id : String,
      name : String,
      body_id : String,
      icon_id : String
   }

type alias Ref = String

--------------------------------------------------------------------------------
-- LOCAL -----------------------------------------------------------------------
--------------------------------------------------------------------------------

--------------------------------------------------------------------------------
-- EXPORTED --------------------------------------------------------------------
--------------------------------------------------------------------------------
none : Type
none =
   {
      id = "cat",
      name = "Black Cat",
      body_id = "mammal",
      icon_id = "cat"
   }

get_id : Type -> String
get_id p = p.id

get_name : Type -> String
get_name p = p.name

get_body_id : Type -> String
get_body_id p = p.body_id

get_icon_id : Type -> String
get_icon_id p = p.icon_id

decoder : (Json.Decode.Decoder Type)
decoder =
   (Json.Decode.succeed
      Type
      |> (Json.Decode.Pipeline.required "id" Json.Decode.string)
      |> (Json.Decode.Pipeline.required "nam" Json.Decode.string)
      |> (Json.Decode.Pipeline.required "bid" Json.Decode.string)
      |> (Json.Decode.Pipeline.required "iid" Json.Decode.string)
   )
