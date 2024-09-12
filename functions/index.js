const functions = require('firebase-functions');
const admin = require('firebase-admin');
admin.initializeApp();

exports.driverRegistration = functions.database
  .ref('/drivers/{driverId}')
  .onCreate(async (snapshot, context) => {
    const driverData = snapshot.val();
    const driverToken = driverData.driver_token; // Driver's FCM token

    const payload = {
      notification: {
        title: 'Profile Submitted',
        body: 'Your profile has been sent for verification. You will be notified once the verification is complete.',
      },
      token: driverToken
    };

    try {
      await admin.messaging().send(payload);
      console.log('Notification sent to driver:', driverData.name);
    } catch (error) {
      console.error('Error sending notification to driver:', error);
    }
  });

exports.notifyAdminOnNewDriverRegistration = functions.database
  .ref('/drivers/{driverId}')
  .onCreate(async (snapshot, context) => {
    const driverData = snapshot.val();
    const adminToken = driverData.admin_token; // Admin's FCM token

    const payload = {
      notification: {
        title: 'New Driver Registration',
        body: `A new driver, ${driverData.name}, has registered. Please review and verify their profile.`,
      },
      token: adminToken
    };

    try {
      await admin.messaging().send(payload);
      console.log('Notification sent to admin for driver:', driverData.name);
    } catch (error) {
      console.error('Error sending notification to admin:', error);
    }
  });

exports.notifyDriverOnVerification = functions.database
  .ref('/drivers/{driverId}/is_verified')
  .onUpdate(async (change, context) => {
    const driverId = context.params.driverId;
    const isVerified = change.after.val(); // Get the new value of is_verified

    if (isVerified) { // If the driver is now verified
      const driverRef = admin.database().ref(`/drivers/${driverId}`);
      const driverSnapshot = await driverRef.once('value');
      const driverData = driverSnapshot.val();
      const driverToken = driverData.driver_token;

      const payload = {
        notification: {
          title: 'Profile Verified',
          body: 'Congratulations! Your profile has been verified. You are now ready to start receiving requests.',
        },
        token: driverToken
      };

      try {
        await admin.messaging().send(payload);
        console.log(`Verification notification sent to driver: ${driverData.name}`);
      } catch (error) {
        console.error('Error sending verification notification to driver:', error);
      }
    }
  });

//exports.notifyDriversOnNewRequest = functions.database
//  .ref("/Ride Request/{rideRequestId}")
//  .onCreate(async (snapshot, context) => {
//    const rideRequestData = snapshot.val();
//    const rideRequestId = context.params.rideRequestId;
//
//    const vehicleType = rideRequestData.v_type;
//
//    // Fetch all drivers who are verified, online, and have the same vehicle type
//    const driversRef = admin.database().ref('/drivers');
//    const driversSnapshot = await driversRef.once('value');
//    const drivers = driversSnapshot.val();
//
//    const tokens = [];
//
//    for (const driverId in drivers) {
//      const driver = drivers[driverId];
//      if (
//        driver.is_verified === true &&
//        driver.is_online === true &&
//        driver.vehicleType === vehicleType
//      ) {
//        if (driver.driver_token) {
//          tokens.push(driver.driver_token);
//        }
//      }
//    }
//
//    if (tokens.length > 0) {
//      // Prepare the notification payload
//      const payload = {
//        notification: {
//          title: "New Ride Request",
//          body: `A new ride request is available for your vehicle type (${vehicleType}).`,
//        },
//        data: {
//          rideRequestId: rideRequestId,
//        },
////        token: tokens
//      };
//
//      // Send the notification to all eligible drivers
//      try {
//        await admin.messaging().sendToDevice(tokens, payload);
//        console.log(`Notification sent to ${tokens.length} drivers`);
//      } catch (error) {
//        console.error("Error sending notification to drivers:", error);
//      }
//    }
//    return null;
//  });

exports.notifyDriversOnNewRequest = functions.database
  .ref("/Ride Request/{rideRequestId}")
  .onCreate(async (snapshot, context) => {
    const rideRequestData = snapshot.val();
    const rideRequestId = context.params.rideRequestId;

    const vehicleType = rideRequestData.v_type;

    // Fetch all drivers who are verified, online, and have the same vehicle type
    const driversRef = admin.database().ref('/drivers');
    const driversSnapshot = await driversRef.once('value');
    const drivers = driversSnapshot.val();

    if (drivers) {
      const notifications = []; // Store all notifications
      const sentTokens = new Set(); // Track tokens that have already been sent

      for (const driverId in drivers) {
        const driver = drivers[driverId];
        if (
          driver.is_verified === true &&
          driver.is_online === true &&
          driver.vehicleType === vehicleType
        ) {
          const driverToken = driver.driver_token;

          if (driverToken && !sentTokens.has(driverToken)) {
            // Prepare the notification payload for the driver
            const driverPayload = {
              notification: {
                title: "New Ride Request",
                body: `A new ride request is available for you. Tap to view details.`,
              },
              data: {
                rideRequestId: rideRequestId,
              },
              token: driverToken
            };
            notifications.push(driverPayload);
            sentTokens.add(driverToken); // Add token to the set
          }
        }
      }

      // Send notifications to all eligible drivers
      try {
        const sendPromises = notifications.map(payload => admin.messaging().send(payload));
        await Promise.all(sendPromises);
        console.log(`Notifications sent to ${notifications.length} drivers`);
      } catch (error) {
        console.error("Error sending notifications to drivers:", error);
      }
    }
    return null;
  });



exports.notifyUserOnRideStart = functions.database
  .ref("/Ride Request/{rideRequestId}/is_started")
  .onUpdate(async (change, context) => {
    const isStarted = change.after.val();
    const rideRequestId = context.params.rideRequestId;

    if (isStarted === true) {
      // Fetch the user token and other details from the ride request
      const rideRequestRef = admin.database().ref(`/Ride Request/${rideRequestId}`);
      const rideRequestSnapshot = await rideRequestRef.once('value');
      const rideRequestData = rideRequestSnapshot.val();
      const userToken = rideRequestData.user_token;

      // Prepare the notification payload
      const payload = {
        notification: {
          title: "Ride Started",
          body: `Your ride with ${rideRequestData.driver_name || "the driver"} has started.`,
        },
        data: {
          rideRequestId: rideRequestId,
        },
        token: userToken
      };

      try {
        await admin.messaging().send(payload);
        console.log(`Notification sent to user: ${rideRequestData.u_id}`);
      } catch (error) {
        console.error("Error sending notification:", error);
      }
    }
    return null;
  });

exports.notifyOnRideCompletion = functions.database
  .ref("/Ride Request/{rideRequestId}/status")
  .onUpdate(async (change, context) => {
    const status = change.after.val();
    const rideRequestId = context.params.rideRequestId;

    if (status === "complete") {
      // Fetch the user and driver tokens and other details from the ride request
      const rideRequestRef = admin.database().ref(`/Ride Request/${rideRequestId}`);
      const rideRequestSnapshot = await rideRequestRef.once('value');
      const rideRequestData = rideRequestSnapshot.val();

      const userToken = rideRequestData.user_token;
      const driverToken = rideRequestData.driver_token;

      // Prepare the notification payload for the user
      const userPayload = {
        notification: {
          title: "Ride Completed",
          body: `Your ride has been successfully completed.`,
        },
        data: {
          rideRequestId: rideRequestId,
        },
        token: userToken
      };

      // Prepare the notification payload for the driver
      const driverPayload = {
        notification: {
          title: "Ride Completed",
          body: `You have successfully completed the ride.`,
        },
        data: {
          rideRequestId: rideRequestId,
        },
        token: driverToken
      };
//      if (userToken) {
      try {
        await admin.messaging().send(userPayload);
        await admin.messaging().send(driverPayload);
        console.log(`Notification sent to user: ${rideRequestData.u_id}`);
      } catch (error) {
        console.error("Error sending notification to user:", error);
      }
//      }

    }
    return null;
  });



/**
 * Import function triggers from their respective submodules:
 *
 * const {onCall} = require("firebase-functions/v2/https");
 * const {onDocumentWritten} = require("firebase-functions/v2/firestore");
 *
 * See a full list of supported triggers at https://firebase.google.com/docs/functions
 */

const {onRequest} = require("firebase-functions/v2/https");
const logger = require("firebase-functions/logger");

// Create and deploy your first functions
// https://firebase.google.com/docs/functions/get-started

// exports.helloWorld = onRequest((request, response) => {
//   logger.info("Hello logs!", {structuredData: true});
//   response.send("Hello from Firebase!");
// });
