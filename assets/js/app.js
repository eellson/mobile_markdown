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
import "idb"

// Import local files
//
// Local files can be imported directly using relative
// paths "./socket" or full ones "web/static/js/socket".

// import socket from "./socket"

const elmDiv = document.querySelector("#elm-target");

if (elmDiv) {
  var app = Elm.Main.embed(elmDiv, {upload_url: UPLOAD_URL});
  app.ports.askPositionForLink.subscribe(function() {
    var textarea = document.getElementById("elm-textarea");
    var cursorPosition = textarea.selectionStart;
    console.log(cursorPosition);
    app.ports.receivePositionForLink.send(cursorPosition);
  });

  navigator.serviceWorker.register("js/sw.js").then(function(reg) {

    app.ports.sendPostToServiceWorker.subscribe(function(payload) {
      console.log("hey");
      if ("sync" in reg) {
        store.outbox("readwrite").then(function(outbox) {
          return outbox.put(payload);
        }).then(function(id) {
          // TODO clean up form?
          return reg.sync.register(id);
        }).catch(function(err) {
          console.error(err);
          // TODO try again?
        });
      }
    });
  }).catch(function(err) {
    console.log(err); // service worker failed to install
  });
}
