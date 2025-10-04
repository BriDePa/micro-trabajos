const express = require("express");
const cors = require("cors");
const port = 3000;
const app = express();
const router = require("./api/endPoints");
app.use(cors());

app.use("/", router);
app.listen(port, () => {
  console.log(`servidor en linea http://localhost:${port}`);
});
