port module Ports exposing (..)

import Json.Encode as Encode exposing (Value)


port askPositionForLink : () -> Cmd msg


port waitForUploadAtPosition : Encode.Value -> Cmd msg


port sendPostResultToIndexedDB : ( Int, String ) -> Cmd msg


port receivePositionForLink : (Int -> msg) -> Sub msg


port receiveCursorAndHash : (Value -> msg) -> Sub msg


port performUpload : (Encode.Value -> msg) -> Sub msg
