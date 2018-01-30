module Model exposing (..)

import FileReader exposing(NativeFile)

type Msg
  = UploadAsset

type alias Model =
  { fileToUpload : Maybe NativeFile
  }

initialModel : Model
initialModel =
  { fileToUpload = Nothing
  }
