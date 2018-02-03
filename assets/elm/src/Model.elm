module Model exposing (..)

-- import FileReader exposing(NativeFile)

type Msg
  = UploadAsset

type alias Model =
  { fileToUpload : Maybe String
  }

initialModel : Model
initialModel =
  { fileToUpload = Nothing
  }
