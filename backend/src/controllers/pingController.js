const db = require("../models/db");

module.exports.ping = (req, res) => {
  const consulta = "SELECT * FROM login";

  try {
    db.query(consulta, (err, resultado) => {
      console.log(resultado);
      res.json(resultado);
    });
  } catch (e) {
    console.log(e);
  }
};
