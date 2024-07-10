#  Twofy

This is the main application that is user facing.

It is responsible for a number of things including:
- Calling into the DB and monitoring for changes.
- Run the manifest installer service to ensure the desired browser can launch the BrowserSupport app.
- Spinning up the `TwofyServiceBroker` launch agent which is used to coordinate XPC communication.

