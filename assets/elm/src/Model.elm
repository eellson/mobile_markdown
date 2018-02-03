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
  { x_amz_credential : String
  , x_amz_date : String
  , x_amz_signature : String
  , policy : String
  }


type alias Flags =
  { upload_url : String
  }

initialModel : Flags -> Model
initialModel flags =
  { fileToUpload = Nothing
  , flags = flags
  }
