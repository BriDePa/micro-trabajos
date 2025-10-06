const db = require("../models/db");

module.exports.login = (req, res) => {
  const { username, password } = req.body;

  const consulta = "SELECT * FROM login WHERE username = ? AND password = ?";

  try {
    db.query(consulta, [username, password], (err, resultado) => {
      if (err) {
        console.error("Error en consulta login:", err);
        return res.status(500).json({ error: "Error en la consulta" });
      }
      if (resultado && resultado.length > 0) {
        console.log("Login OK:", resultado);
        return res.json(resultado);
      } else {
        return res
          .status(401)
          .json({ mensaje: "usuario o contraseña incorrecta" });
      }
    });
  } catch (error) {
    console.error("Exception en login handler:", error);
    return res.status(500).json({ error: "Error del servidor" });
  }
};
