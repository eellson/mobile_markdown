module View exposing (..)

import Model exposing (..)
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import FileReader exposing (parseSelectedFiles)
import Json.Decode as Json


editorView : Model -> Html Msg
editorView model =
    div [ class "row" ]
        [ input
            [ type_ "file"
            , on "change" (Json.map Files parseSelectedFiles)
            ]
            []
        , textarea
            [ onInput TextEntered
            , value model.textAreaContents
            , id "elm-textarea"
            ]
            []
        ]
