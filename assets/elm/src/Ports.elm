port module Ports exposing (..)

import Model exposing (UploadPayload)


port askPositionForLink : () -> Cmd msg


port sendPostToServiceWorker : UploadPayload -> Cmd msg


port receivePositionForLink : (Int -> msg) -> Sub msg
