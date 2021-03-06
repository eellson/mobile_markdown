// https://www.twilio.com/blog/2017/02/send-messages-when-youre-back-online-with-service-workers-and-background-sync.html
// https://philna.sh/blog/2017/07/04/experimenting-with-the-background-fetch-api/

importScripts("/js/idb.js");
importScripts("/js/store.js");

self.addEventListener('activate', event => {
  event.waitUntil(clients.claim());
});

self.addEventListener("sync", function(event) {
  console.log("hello sw");
  console.log(event);
  event.waitUntil(
    uploadSuccessful(event.tag)
  );
});

function uploadSuccessful(postId) {
  return store.outbox("readonly"
  ).then(function(outbox) {
    return outbox.get(parseInt(postId));
  }).then(function(upload) {
    if (upload.status == "succeeded") {
      return Promise.resolve();
    } else {
      clients.matchAll().then(function(clients) {
        channel = new MessageChannel();
        clients.forEach(function(client) {
          client.postMessage(upload, [channel.port2]);
        });
      });
      return Promise.reject(new Error("upload not succeeded"));
    }
  });
}
