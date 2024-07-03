// background.js

// Function to send message to native host
function sendMessageToNativeHost(message) {
  chrome.runtime.sendNativeMessage('me.foureyes.twofy', message, function(response) {
    if (chrome.runtime.lastError) {
      console.error("Error: " + chrome.runtime.lastError.message);
    } else {
      console.log("Received response:", response);
    }
  });
}

// Example JSON blob
const jsonBlob = {
  // Add your desired properties here
  "action": "ping"
};

// Send message when extension is installed or updated
chrome.runtime.onInstalled.addListener(function() {
  sendMessageToNativeHost(jsonBlob);
});

// Optional: Add button to send message
chrome.action.onClicked.addListener(function(tab) {
  sendMessageToNativeHost(jsonBlob);
});
