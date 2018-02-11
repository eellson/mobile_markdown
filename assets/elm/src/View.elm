module View exposing (..)

import Model exposing (..)
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import FileReader exposing (parseSelectedFiles)
import Json.Decode as Json


editorView : Model -> Html Msg
editorView model =
    div [ class "flex-container-full-height" ]
        [ textarea
            [ onInput TextEntered
            , value model.textAreaContents
            , id "elm-textarea"
            , class "markdown-editor"
            ]
            []
        , label [ class "markdown-asset-upload" ]
            [ text "Insert image"
            , input
                [ type_ "file"
                , on "change" (Json.map Files parseSelectedFiles)
                ]
                []
            ]
        ]
