module Model exposing (..)

import FileReader exposing(NativeFile)
import Http exposing(Request)

type Msg
  = UploadAsset
  | Files (List NativeFile)
  | CredentialsResult (Result Http.Error Credentials)
  | UploadComplete (Result Http.Error String)

type alias Model =
  { fileToUpload : Maybe NativeFile
  , flags : Flags
  }

type alias Credentials =
  { credential : String
  , date : String
  , policy : String
  , signature : String
  }


type alias Flags =
  { upload_url : String
  }

initialModel : Flags -> Model
initialModel flags =
  { fileToUpload = Nothing
  , flags = flags
  }
