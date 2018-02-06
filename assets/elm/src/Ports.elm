port module Ports exposing (..)

port askPositionForLink : () -> Cmd msg

port receivePositionForLink : (Int -> msg) -> Sub msg
