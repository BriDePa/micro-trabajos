const mysql = require("mysql");
const db = mysql.createConnection({
  host: "localhost",
  user: "root",
  password: "1201",
  database: "auth",
});
module.exports = db;
db.connect((err) => {
  if (err) {
    console.log("error de la consola", err);
  }
});
