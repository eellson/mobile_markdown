# MobileMarkdown

An experiment in creating a simple markdown editor supplemented with the ability
to programmatically insert img tags, handling upload attempts when the user is
offline, or sufferring from a dodgy connection:

![](/mobile-markdown-demo.gif)

MobileMarkdown is a Phoenix app exposing the following endpoints:

## /editor

The entrypoint into the user-facing application. On this view we render a
textarea and file input, allowing the user to compose markdown, and insert img
tags for newly uploaded files programmatically.

## /credentials

This endpoint returns a time-limited credential allowing the user to upload
files to Amazon S3.

## /fake_upload/new

An endpoint for development, returning a mock AWS signature response.

### Implementation details

The Elixir application has 2 responsibilities:

* A simple web applicaition implemented using Phoenix;
* An `AWSSigV4` context, handling generation of values required for authenticated
uploads to Amazon S3.
  * `AWSSigV4` is the main public interface for this functionality. Calling
  `get_credential/5` returns a `%Credential{}` populated with values allowing
  upload to S3, with a simple default policy.
  * `AWSSigV4.Credential` knows nothing about S3, but handles constructing a
  credential string, and encoded signature based upon provided values (for
  instance date, AWS service, string to be signed)
  * `AWSSigV4.S3` handles S3-specific functionality; exposing functions for
  returning a policy document given some conditions, and a date string formatted
  correctly for this service.

On the front end, we have some vanilla js, and an Elm application:

#### app.js

* On loading the editor, we initialize the Elm application in a target div;
* We then register a service worker, and subscribe to Elm ports for upload
attempt, and upload success;
  * The upload success port, `waitForUploadAtPosition`, gets the current cursor
  position, and writes the passed file json to a new row in IndexedDB. We then
  pass the cursor and row ID back to Elm, across the `receiveCursorAndId` port.
  * Next, we call the Service Worker's `sync` method with the ID. Sync makes use
  of retries and backoffs, to handle offline or dodgy connections:
    * First, get the row from IndexedDB, by ID;
    * Next check if this upload is already complete, by looking at the value of
    a `status` field.
    * If this is `succeeded`, we have finished this upload already, so we
    resolve.
    * Otherwise, we want to attempt the upload, so send a message back to the
    Service Worker's client, with the file value.
    * When the client receives this message, we send the data back to Elm, over
    the `performUpload` port.
  * When  we receive the upload success message over `uploadSuccessful`, we
  update the row found by the provided ID to have `succeeded` status.

#### Elm

The Elm app is responsible for rendering the editor, keeping track of and
updating editor state, fetching credentials and attempting uploads.

* When a user selects a file for the file input, we parse this value to JSON,
then send a message through the `waitForUploadAtPosition` port, asking javascript
to get the current position of the cursor.
* When we receive a message through the `receiveCursorAndId` port, we insert a
temporary img tag at the provided position, using the passed ID as a temporary
key instead of an image URL.
* When receiving a message over the `performUpload` port, we decode the file
json into a NativeFile value, and then attempt the upload:
  * first get the credentials
  * now use this response in an attempt to upload to S3
  * If this is successful, we update the temporary img tag with the returned
  image URL, and send a message to js over the `uploadSuccessful` port.

## Running the app

You'll need to set some AWS values in your config&mdash;some are secret, so don't commit this!

### config/dev.secret.exs
```elixir
use Mix.Config

config :mobile_markdown, :s3_post_config,
  endpoint: "http://bucket-website.com.s3.amazonaws.com/",
  bucket: "bucket-website.com",
  region: "us-east-1",
  ttl: 30,
  public_key: "PUBLIC",
  private_key: "SECRET"

```

To start your Phoenix server:

  * Install dependencies with `mix deps.get`
  * Create and migrate your database with `mix ecto.create && mix ecto.migrate`
  * Install Node.js dependencies with `cd assets && npm install`
  * Start Phoenix endpoint with `mix phx.server`

Now you can visit [`localhost:4000`](http://localhost:4000) from your browser.
