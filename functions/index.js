const { onCall } = require("firebase-functions/v2/https");
const admin = require("firebase-admin");

admin.initializeApp();

exports.recursiveDelete = onCall({ region: "asia-northeast1" }, async (request) => {
    if (!request.auth) {
      throw new Error("unauthenticated");
    }
    const path = request.data.path;
    if (!path) {
      throw new Error("path required");
    }
    const ref = admin.firestore().doc(path);
    await admin.firestore().recursiveDelete(ref);
    return { success: true };
});