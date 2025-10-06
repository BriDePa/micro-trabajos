const express = require("express");
const cors = require("cors");
const port = 3000;
const app = express();
const router = require("./api/endPoints");
app.use(express.json());
app.use(
  cors({
    origin: "http://localhost:5173",
    methods: ["GET", "POST"],
  })
);


app.use("/", router);

app.listen(port, () => {
  console.log(`servidor en linea http://localhost:${port}`);
});
