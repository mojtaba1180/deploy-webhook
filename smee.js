const SmeeClient = require("smee-client");

const smee = new SmeeClient({
  source: "https://smee.io/b38GL322RzVdWV9V",
  target: "http://localhost:3000/webhook",
  logger: console,
});

// const events = smee.start();
smee.start();

// Stop forwarding events
// events.close();
