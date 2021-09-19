importScripts("https://www.gstatic.com/firebasejs/7.20.0/firebase-app.js");
importScripts("https://www.gstatic.com/firebasejs/7.20.0/firebase-messaging.js");

firebase.initializeApp({
  apiKey: "AIzaSyC5UrZsnrWt9rKpjXg8QDqOS7orvvYBjFY",
  authDomain: "quickitchen-dotma.firebaseapp.com",
  projectId: "quickitchen-dotma",
  storageBucket: "quickitchen-dotma.appspot.com",
  messagingSenderId: "999380152523",
  appId: "1:999380152523:web:bfe236afa718f9ec0b2b4e",
  databaseURL: "...",
});

const messaging = firebase.messaging();

// Optional:
messaging.onBackgroundMessage((message) => {
  console.log("onBackgroundMessage", message);
});