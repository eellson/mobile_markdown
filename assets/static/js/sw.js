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
  event.waitUntil(uploadSuccessful(event.tag));
});

function uploadSuccessful(postId) {
  store.outbox("readonly"
  ).then(function(outbox) {
    console.log("2nd");
    return outbox.get(parseInt(postId));
  }).then(function(upload) {
    console.log(upload);
    if (upload.status == "succeeded") {
      Promise.resolve("succeeded");
    }
    return upload;
  }).then(function(upload) {
    console.log("next send 2 client");
    clients.matchAll({includeUncontrolled: true, type: 'window'}).then(function(clients) {
      console.log(clients);
      clients.forEach(function(client) {
        new Promise(function(resolve, reject) {
          channel = new MessageChannel();
          channel.port1.onmessage = function(event) {
            if (event.data.error) {
              console.error(event.data.error);
              reject(event.data.error);
            } else {
              console.log(event.data);
              resolve(event.data);
            }
          };

          console.log(upload);
          client.postMessage(upload, [channel.port2]);
        });
      });
    });
  }).catch(function(err) {
    console.error(err);
    return err;
  });
}
