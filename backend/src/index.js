const express = require("express");
const cors = require("cors");
const port = 3000;
const app = express();
app.use(cors());

app.get("/", (req, res) => {
  res.send("hello friend");
});

app.listen(port, () => {
  console.log(`servidor en linea http://localhost:${port}`);
});
