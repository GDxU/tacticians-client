module View.SubMenu.Status.CharacterInfo exposing (get_html)

-- Elm -------------------------------------------------------------------------
import Html
import Html.Attributes

-- Struct.Battlemap -------------------------------------------------------------------
import Struct.Character
import Struct.Event

import View.Controlled.CharacterCard

--------------------------------------------------------------------------------
-- LOCAL -----------------------------------------------------------------------
--------------------------------------------------------------------------------

--------------------------------------------------------------------------------
-- EXPORTED --------------------------------------------------------------------
--------------------------------------------------------------------------------
get_html : (
      Int ->
      Struct.Character.Type ->
      (Html.Html Struct.Event.Type)
   )
get_html player_ix char =
   (Html.div
      [
         (Html.Attributes.class "tabmenu-character-info")
      ]
      [
         (Html.text ("Focusing:")),
         (View.Controlled.CharacterCard.get_full_html player_ix char)
      ]
   )
