// https://www.twilio.com/blog/2017/02/send-messages-when-youre-back-online-with-service-workers-and-background-sync.html
// https://philna.sh/blog/2017/07/04/experimenting-with-the-background-fetch-api/

// importScripts("store.js");

self.addEventListener("sync", function(event) {
  console.log("hello sw");
  console.log(event);
  event.waitUntil(uploadSuccessful(event.tag));
});

function uploadSuccessful(postId) {
  // store.outbox("readonly"
  // ).then(function(outbox) {
  //   console.log("2nd");
  //   return outbox.get(parseInt(postId));
  // }).then(function(upload) {
  //   if (upload.status == "succeeded") {
  //     Promise.resolve("succeeded");
  //   }
  // }).then(function(upload) {
  //   app.ports.performUpload.send(upload);
  // }).catch(function(err) {
  //   console.error(err);
  //   return err;
  // });
}
