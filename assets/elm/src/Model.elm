module Model exposing (..)

import FileReader exposing (NativeFile)
import Http exposing (Request)
import Json.Encode exposing (Value)


type Msg
    = UploadAsset Json.Encode.Value
    | Files (List NativeFile)
    | UploadComplete Int (Result Http.Error String)
    | TextEntered String
    | InsertImageTag Json.Encode.Value


type alias Model =
    { fileToUpload : Maybe NativeFile
    , flags : Flags
    , textAreaContents : String
    , lastCursorPosition : Int
    }


type alias Credentials =
    { x_amz_credential : String
    , x_amz_date : String
    , x_amz_signature : String
    , x_amz_algorithm : String
    , policy : String
    }


type alias Flags =
    { upload_url : String
    }


type alias CursorId =
    { position : Int
    , id : Int
    }


type alias NativeFileAndId =
    { file : NativeFile
    , id : Int
    }


initialModel : Flags -> Model
initialModel flags =
    { fileToUpload = Nothing
    , flags = flags
    , textAreaContents = ""
    , lastCursorPosition = 0
    }
