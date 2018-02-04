module Main exposing (..)

import Model exposing (..)
import View
import Html
import Http exposing(stringPart, Request)
import Json.Decode exposing (Decoder)
import FileReader exposing (NativeFile)
import Xml exposing (Value(..))
import Xml.Encode exposing (null)
import Xml.Decode exposing (decode)
import Xml.Query exposing (tag, string)

main : Program Flags Model Msg
main =
  Html.programWithFlags
  { init = initialState
  , update = update
  , view = View.editorView
  , subscriptions = (\_ -> Sub.none)
  }

initialState : Flags -> ( Model, Cmd Msg )
initialState flags =
  (initialModel flags, Cmd.none)

update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
  case msg of
    UploadAsset ->
      let
        cmd =
          Http.get "/api/credentials" credentialsDecoder
          |> Http.send CredentialsResult
      in
      model ! [ cmd ]

    Files nativeFiles ->
      { model | fileToUpload = List.head nativeFiles } ! []

    CredentialsResult (Ok result) ->
      let
        cmd =
          model.fileToUpload
          |> Maybe.map
            (\file ->
              uploadRequest result file model.flags
              |> Http.send UploadComplete
            )
          |> Maybe.withDefault Cmd.none
      in
        model ! [ cmd ]

    CredentialsResult (Err error) ->
      let
        _ =
          Debug.log "error" error
      in
        model ! []

    UploadComplete (Ok result) ->
      let
        _ =
          Debug.log "result" result

        newState =
          result
          |> getUploadUrl
          |> constructMarkdown
          |> (++) model.textAreaContents
      in
        {model | textAreaContents = newState} ! []

    UploadComplete (Err error) ->
      let
        _ =
          Debug.log "error" error
      in
        model ! []

    TextEntered newState ->
      { model | textAreaContents = newState } ! []

uploadRequest : Credentials -> NativeFile -> Flags -> Request String
uploadRequest creds file flags =
  Http.request
  { method = "POST"
  , headers = []
  , url = flags.upload_url
  , body = multiPartBody creds file
  , expect = Http.expectString
  , timeout = Nothing
  , withCredentials = False
  }


multiPartBody : Credentials -> NativeFile -> Http.Body
multiPartBody creds nf =
  Http.multipartBody
  [ stringPart "key" nf.name
  , stringPart "x-amz-algorithm" "AWS4-HMAC-SHA256"
  , stringPart "x-amz-credential" creds.x_amz_credential
  , stringPart "x-amz-date" creds.x_amz_date
  , stringPart "x-amz-signature" creds.x_amz_signature
  , stringPart "policy" creds.policy
  , stringPart "success_action_status" "201"
  , FileReader.filePart "file" nf
  ]


credentialsDecoder : Decoder Credentials
credentialsDecoder =
  Json.Decode.map4 Credentials
    (Json.Decode.at ["data", "x_amz_credential"] Json.Decode.string)
    (Json.Decode.at ["data", "x_amz_date"] Json.Decode.string)
    (Json.Decode.at ["data", "x_amz_signature"] Json.Decode.string)
    (Json.Decode.at ["data", "policy"] Json.Decode.string)

getUploadUrl : String -> Result String String
getUploadUrl xmlString =
  xmlString
  |> decode
  |> Result.toMaybe
  |> Maybe.withDefault null
  |> tag "Location" Xml.Query.string

constructMarkdown : Result String String -> String
constructMarkdown result =
  case result of
    Ok string ->
      "![](" ++ string ++ ")"
    Err err ->
      ""
