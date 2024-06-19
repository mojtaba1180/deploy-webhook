const express = require("express");
const bodyParser = require("body-parser");
const cors = require("cors");
const { exec } = require("child_process");
const app = express();
const port = 3000;

const SECRET = "xPKG6QrX54qMjSZEYHusyBJFfm8Lw2";

app.use(cors());
app.use(bodyParser.json());

app.post("/webhook", (req, res) => {
  const token = req.headers["x-auth-token"];
  if (token !== SECRET) {
    return res.status(403).send("Forbidden");
  }

  console.log("Webhook received:", req.body);

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
