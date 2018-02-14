// Brunch automatically concatenates all files in your
// watched paths. Those paths can be configured at
// config.paths.watched in "brunch-config.js".
//
// However, those files will only be executed if
// explicitly imported. The only exception are files
// in vendor, which are never wrapped in imports and
// therefore are always executed.

// Import dependencies
//
// If you no longer want to use a dependency, remember
// to also remove its path from "config.paths.watched".
import "phoenix_html"

// Import local files
//
// Local files can be imported directly using relative
// paths "./socket" or full ones "web/static/js/socket".

// import socket from "./socket"

const elmDiv = document.querySelector("#elm-target");

if (elmDiv) {
  var app = Elm.Main.embed(elmDiv, {upload_url: UPLOAD_URL});

  navigator.serviceWorker.register("/sw.js", {"scope": "/editor"}).then(function(reg) {

    app.ports.waitForUploadAtPosition.subscribe(function(payload) {
      console.log(payload);

      var textarea = document.getElementById("elm-textarea");
      var cursorPosition = textarea.selectionStart;

      store.outbox("readwrite").then(function(outbox) {
        var row = {"file": payload, "status": "pending"}
        return outbox.put(row);
      }).then(function(id) {
        app.ports.receiveCursorAndId.send(
          {"position": cursorPosition, "id": id});

        // TODO clean up form?
        console.log(id);
        return reg.sync.register(id);
      }).catch(function(err) {
        console.error(err)
        // TODO try again?
      });
    });

    app.ports.uploadSuccessful.subscribe(function(id) {
      store.outbox("readwrite").then(function(outbox) {
        var row = {"status": "succeeded", "id": parseInt(id)}
        console.log(row);
        return outbox.put(row);
      });
    });

    navigator.serviceWorker.addEventListener("message", function(event) {
      console.log("client message");
      console.log(event);
      app.ports.performUpload.send(event.data);
    });
  }).catch(function(err) {
    console.log(err); // service worker failed to install
  });
}

console.log(store);
