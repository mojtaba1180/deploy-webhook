const express = require("express");
const bodyParser = require("body-parser");
const cors = require("cors");
const crypto = require("crypto");
const { exec } = require("child_process");
const app = express();
const port = 3000;

const SECRET = "xPKG6QrX54qMjSZEYHusyBJFfm8Lw2";

app.use(cors());
app.use(
  bodyParser.json({
    verify: (req, res, buf) => {
      req.rawBody = buf.toString(); // Ensure raw body is a string
    },
  }),
);

app.post("/webhook", (req, res) => {
  // Log all headers to diagnose
  console.log("Received headers:", req.headers);

  const signature = req.headers["x-hub-signature"];
  console.log("Received signature:", signature);
  if (!signature) {
    return res.status(403).send("Forbidden: No signature provided");
  }

  const hmac = crypto.createHmac("sha256", SECRET);
  const digest = "sha256=" + hmac.update(req.rawBody).digest("hex");

  console.log("Computed digest:", digest);
  console.log("Webhook received:", req.body);

  if (signature !== digest) {
    return res.status(403).send("Forbidden: Invalid signature");
  }

  console.log("Webhook payload:", req.body.test);

  if (req.body.test) {
    return res.send("success Testing");
  }

  // Trigger your deployment script/command
  exec("sh ./deploy_script.sh", (error, stdout, stderr) => {
    if (error) {
      console.error(`Error executing script: ${error}`);
      return res.status(500).send("Deployment failed");
    }
    console.log(`stdout: ${stdout}`);
    console.error(`stderr: ${stderr}`);
    res.send("Deployment successful");
  });
});

app.get("/", (req, res) => {
  res.send("success");
});

app.listen(port, () => {
  console.log(`Webhook server listening at http://localhost:${port}`);
});
