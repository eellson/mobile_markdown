port module Ports exposing (..)

import Json.Encode as Encode exposing (Value)


port waitForUploadAtPosition : Encode.Value -> Cmd msg


port receiveCursorAndHash : (Value -> msg) -> Sub msg


port performUpload : (Encode.Value -> msg) -> Sub msg
