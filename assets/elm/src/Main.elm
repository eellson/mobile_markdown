module Main exposing (..)

import Model exposing (..)
import View
import Html
import Http exposing(stringPart, Request)
import Json.Decode exposing (Decoder)
import FileReader exposing (NativeFile)

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
          Http.get "/credentials" credentialsDecoder
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
      in
        model ! []

    UploadComplete (Err error) ->
      let
        _ =
          Debug.log "error" error
      in
        model ! []

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
  , stringPart "x-amz-credential" creds.credential
  , stringPart "x-amz-date" creds.date
  , stringPart "policy" creds.policy
  , stringPart "x-amz-signature" creds.signature
  , FileReader.filePart "file" nf
  ]


credentialsDecoder : Decoder Credentials
credentialsDecoder =
  Json.Decode.map4 Credentials
    (Json.Decode.field "credential" Json.Decode.string)
    (Json.Decode.field "date" Json.Decode.string)
    (Json.Decode.field "policy" Json.Decode.string)
    (Json.Decode.field "signature" Json.Decode.string)
