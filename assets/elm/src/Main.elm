module Main exposing (..)

import Model exposing (..)
import View
import Ports
import Html
import Http exposing (stringPart, Request)
import Json.Encode as Encode exposing (encode)
import Json.Decode exposing (Decoder)
import Task exposing (..)
import FileReader exposing (NativeFile)
import Xml exposing (Value(..))
import Xml.Encode exposing (null)
import Xml.Decode exposing (decode)
import Xml.Query exposing (tag, string)
import MimeType
import Regex exposing (regex, replace)


main : Program Flags Model Msg
main =
    Html.programWithFlags
        { init = initialState
        , update = update
        , view = View.editorView
        , subscriptions = subscriptions
        }


initialState : Flags -> ( Model, Cmd Msg )
initialState flags =
    ( initialModel flags, Cmd.none )


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        InsertImageTag posIdValue ->
            let
                positionAndId =
                    posIdValue
                        |> Json.Decode.decodeValue cursorIdDecoder
            in
                (insertImageTag model positionAndId) ! []

        UploadAsset fileValue ->
            let
                fileAndId =
                    fileValue
                        |> Json.Decode.decodeValue nativeFileAndIdDecoder
            in
                model ! [ credentialsAndUpload model fileAndId ]

        Files nativeFiles ->
            let
                cmd =
                    nativeFiles
                        |> List.head
                        |> fileJson
                        |> Ports.waitForUploadAtPosition
            in
                model ! [ cmd ]

        UploadComplete id (Ok result) ->
            let
                _ =
                    Debug.log "result" result

                url =
                    getUploadUrl result

                cmd =
                    Ports.uploadSuccessful id
            in
                (updateImageTag model id url) ! [ cmd ]

        UploadComplete _ (Err error) ->
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
        , stringPart "x-amz-algorithm" creds.x_amz_algorithm
        , stringPart "x-amz-credential" creds.x_amz_credential
        , stringPart "x-amz-date" creds.x_amz_date
        , stringPart "x-amz-signature" creds.x_amz_signature
        , stringPart "policy" creds.policy
        , stringPart "success_action_status" "201"
        , FileReader.filePart "file" nf
        ]


getUploadUrl : String -> Result String String
getUploadUrl xmlString =
    xmlString
        |> decode
        |> Result.toMaybe
        |> Maybe.withDefault null
        |> tag "Location" Xml.Query.string


wrapUrl : Int -> String
wrapUrl int =
    "![](" ++ toString int ++ ")"


fileJson : Maybe NativeFile -> Encode.Value
fileJson nativeFile =
    case nativeFile of
        Just file ->
            file.blob

        _ ->
            Encode.null


credentialsDecoder : Decoder Credentials
credentialsDecoder =
    let
        _ =
            Debug.log "creds"

        decode =
            Json.Decode.map5 Credentials
                (Json.Decode.at [ "data", "x_amz_credential" ] Json.Decode.string)
                (Json.Decode.at [ "data", "x_amz_date" ] Json.Decode.string)
                (Json.Decode.at [ "data", "x_amz_signature" ] Json.Decode.string)
                (Json.Decode.at [ "data", "x_amz_algorithm" ] Json.Decode.string)
                (Json.Decode.at [ "data", "policy" ] Json.Decode.string)
    in
        decode


cursorIdDecoder : Decoder CursorId
cursorIdDecoder =
    Json.Decode.map2 CursorId
        (Json.Decode.field "position" Json.Decode.int)
        (Json.Decode.field "id" Json.Decode.int)


mtypeDecoder : Decoder (Maybe MimeType.MimeType)
mtypeDecoder =
    Json.Decode.map MimeType.parseMimeType (Json.Decode.field "type" Json.Decode.string)


nativeFileDecoder : Decoder NativeFile
nativeFileDecoder =
    Json.Decode.map4 NativeFile
        (Json.Decode.field "name" Json.Decode.string)
        (Json.Decode.field "size" Json.Decode.int)
        mtypeDecoder
        Json.Decode.value


nativeFileAndIdDecoder : Decoder NativeFileAndId
nativeFileAndIdDecoder =
    Json.Decode.map2 NativeFileAndId
        (Json.Decode.field "file" nativeFileDecoder)
        (Json.Decode.field "id" Json.Decode.int)


insertImageTag : Model -> Result String CursorId -> Model
insertImageTag model positionAndId =
    case positionAndId of
        Ok values ->
            let
                toPrepend =
                    String.left values.position model.textAreaContents

                uploadString =
                    wrapUrl values.id

                toAppend =
                    String.dropLeft values.position model.textAreaContents

                newState =
                    String.concat [ toPrepend, uploadString, toAppend ]
            in
                { model | textAreaContents = newState }

        Err error ->
            let
                _ =
                    Debug.log "error" error
            in
                model


credentialsAndUpload : Model -> Result String NativeFileAndId -> Cmd Msg
credentialsAndUpload model fileAndId =
    case fileAndId of
        Ok fileAndId ->
            let
                creds =
                    Http.get "/api/credentials" credentialsDecoder

                upload =
                    \creds_result ->
                        uploadRequest creds_result fileAndId.file model.flags

                requests =
                    Http.toTask creds
                        |> Task.andThen (\result -> Http.toTask (upload result))

                cmd =
                    Task.attempt (UploadComplete fileAndId.id) requests
            in
                cmd

        Err error ->
            let
                _ =
                    Debug.log "error" error
            in
                Cmd.none


updateImageTag : Model -> Int -> Result String String -> Model
updateImageTag model id url =
    case url of
        Ok url ->
            let
                replace =
                    Regex.replace Regex.All (regex (toString id)) (\_ -> url)

                newState =
                    replace model.textAreaContents
            in
                { model | textAreaContents = newState }

        Err error ->
            let
                _ =
                    Debug.log "error" error
            in
                model


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.batch
        [ Ports.receiveCursorAndId InsertImageTag
        , Ports.performUpload UploadAsset
        ]
