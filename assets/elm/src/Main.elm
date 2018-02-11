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
        InsertImageTag posHashValue ->
            let
                positionAndHash =
                    posHashValue
                        |> Json.Decode.decodeValue cursorHashDecoder
            in
                case positionAndHash of
                    Ok values ->
                        let
                            toPrepend =
                                model.textAreaContents
                                    |> String.left values.position

                            uploadString =
                                values.hash
                                    |> wrapUrl

                            toAppend =
                                model.textAreaContents
                                    |> String.dropLeft values.position

                            newState =
                                String.concat
                                    [ toPrepend
                                    , uploadString
                                    , toAppend
                                    ]
                        in
                            { model | textAreaContents = newState } ! []

                    _ ->
                        model ! []

        TryUploadAsset fileValue ->
            let
                nativeFileAndHash =
                    fileValue
                        |> Json.Decode.decodeValue nativeFileAndHashDecoder
            in
                case nativeFileAndHash of
                    Ok fileAndHash ->
                        let
                            requests =
                                Http.toTask (Http.get "/api/credentials" credentialsDecoder)
                                    |> Task.andThen
                                        (\result ->
                                            (Http.toTask (uploadRequest result fileAndHash.file model.flags))
                                        )

                            cmd =
                                Task.attempt (UploadComplete fileAndHash.hash) requests
                        in
                            model ! [ cmd ]

                    Err err ->
                        let
                            _ =
                                Debug.log "TryUploadAsset" err
                        in
                            model ! []

        Files nativeFiles ->
            let
                cmd =
                    Ports.askPositionForLink ()
            in
                { model | fileToUpload = List.head nativeFiles } ! [ cmd ]

        DeferFiles nativeFiles ->
            let
                cmd =
                    nativeFiles
                        |> List.head
                        |> fileJson
                        |> Ports.waitForUploadAtPosition
            in
                model ! [ cmd ]

        UploadComplete hash (Ok result) ->
            let
                _ =
                    Debug.log "result" result

                url =
                    result
                        |> getUploadUrl
            in
                case url of
                    Ok url ->
                        let
                            replace =
                                Regex.replace Regex.All (regex hash) (\_ -> url)

                            newState =
                                replace model.textAreaContents
                        in
                            { model | textAreaContents = newState } ! []

                    Err err ->
                        let
                            _ =
                                Debug.log "error" err
                        in
                            model ! []

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
            wrapUrl string

        Err err ->
            ""


wrapUrl : String -> String
wrapUrl string =
    "![](" ++ string ++ ")"


fileJson : Maybe NativeFile -> Encode.Value
fileJson nativeFile =
    case nativeFile of
        Just file ->
            file.blob

        _ ->
            Encode.null


cursorHashDecoder : Decoder CursorHash
cursorHashDecoder =
    Json.Decode.map2 CursorHash
        (Json.Decode.field "position" Json.Decode.int)
        (Json.Decode.field "hash" Json.Decode.string)


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.batch
        [ Ports.receiveCursorAndHash InsertImageTag
        , Ports.performUpload TryUploadAsset
        ]


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


nativeFileAndHashDecoder : Decoder NativeFileAndHash
nativeFileAndHashDecoder =
    Json.Decode.map2 NativeFileAndHash
        (Json.Decode.field "file" nativeFileDecoder)
        (Json.Decode.field "hash" Json.Decode.string)
