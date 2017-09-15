module View exposing (view)

import Html exposing (Html, button, div, text, table, tr, td)
import Html.Events exposing (onClick)

import Update exposing (..)
import Model exposing (Model)

import Battlemap.Html as Batmap exposing (view)
import Battlemap.Direction exposing (..)

-- VIEW

view : Model -> (Html Msg)
view model =
   (div
      []
      [
         (button
            [ (onClick (DirectionRequest Left)) ]
            [ (text "Left") ]
         ),
         (button
            [ (onClick (DirectionRequest Down)) ]
            [ (text "Down") ]
         ),
         (button
            [ (onClick (DirectionRequest Up)) ]
            [ (text "Up") ]
         ),
         (button
            [ (onClick (DirectionRequest Right)) ]
            [ (text "Right") ]
         ),
         (div
            []
            [(Batmap.view model)]
         )
      ]
   )
