// Create a long-lived port to ensure we're not spinning up the
// native app process and spinning it down with each message.
const port = chrome.runtime.connectNative("me.foureyes.twofy");

// Hook to handle responses coming from the native connection.
port.onMessage.addListener(function (response) {
  if (chrome.runtime.lastError) {
    console.error("Error: " + chrome.runtime.lastError.message);
  } else {
    chrome.tabs.query({ active: true }, function (tabs) {
      for (const tab of tabs) {
        chrome.tabs.sendMessage(tab.id, response, function (response) {});
      }
    });
  }
});

port.onDisconnect.addListener(function (disconnected) {
  console.log("Port was disconnected!");
});

// Example JSON blob
const jsonBlob = {
  // Add your desired properties here
  action: "ping",
};

// Send message when extension is installed or updated
chrome.runtime.onInstalled.addListener(function () {
  port.postMessage(jsonBlob);
});
