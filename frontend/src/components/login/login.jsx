import { Button } from "@mui/material";
import React from "react";

const Login = () => {
  const [password, setPassword] = React.useState("");
  const [username, setUsername] = React.useState("");

  const handleLogin = async (e) => {
    e.preventDefault();
    console.log("1. Ejecutando login...");
    console.log("2. Datos a enviar:", { username, password });

    const data = { username, password };


    try {
      console.log("3. Haciendo fetch...");

      const response = await fetch("http://localhost:3000/login", {
        method: "POST",
        headers: {
          "Content-Type": "application/json",
        },
        body: JSON.stringify(data),
      });

      console.log("4. Response recibida:", response);
      console.log("5. Status:", response.status);
      console.log("6. Response OK?:", response.ok);

      const result = await response.json();
      console.log("7. Resultado parseado:", result);

      if (response.ok) {
        console.log("8. Login exitoso!");
        alert("Login exitoso");
      } else {
        console.log("9. Login fallido");
        alert(`Error: ${result.error || "Credenciales inválidas"}`);
      }
    } catch (error) {
      console.error("10. Error capturado:", error);
      alert("Error de conexión");
    }
  };

  return (
    <div className="min-h-screen flex items-center justify-center bg-gradient-to-br from-slate-50 p-6 bg-blue-950">
      <div className="w-full max-w-md bg-white rounded-2xl shadow-lg p-8">
        <h2 className="text-2xl font-semibold text-gray-800 mb-4">
          Bienvenido
        </h2>
        <p className="text-sm text-gray-500 mb-6">
          Ingresa tus credenciales para continuar
        </p>

        {/* ✅ AGREGADO onSubmit aquí */}
        <form className="space-y-4" onSubmit={handleLogin}>
          <div>
            <label className="block text-sm font-medium text-gray-700">
              Usuario
            </label>
            <input
              value={username} // ✅ Agregado value
              onChange={(e) => setUsername(e.target.value)}
              type="text"
              required // ✅ Validación HTML
              className="mt-1 block w-full rounded-lg border border-gray-200 px-3 py-2 text-sm shadow-sm placeholder-gray-400 focus:outline-none focus:ring-2 focus:ring-indigo-400"
            />
          </div>

          <div>
            <label className="block text-sm font-medium text-gray-700">
              Contraseña
            </label>
            <input
              value={password} // ✅ Agregado value
              onChange={(e) => setPassword(e.target.value)}
              type="password"
              required // ✅ Validación HTML
              className="mt-1 block w-full rounded-lg border border-gray-200 px-3 py-2 text-sm shadow-sm placeholder-gray-400 focus:outline-none focus:ring-2 focus:ring-indigo-400"
            />
          </div>

          <div className="flex items-center justify-between">
            <label className="inline-flex items-center text-sm">
              <input
                type="checkbox"
                className="h-4 w-4 rounded border-gray-300 text-indigo-600 focus:ring-indigo-500"
              />
              <span className="ml-2 text-gray-600">Recordarme</span>
            </label>
            <a href="#" className="text-sm text-indigo-600 hover:underline">
              ¿Olvidaste tu contraseña?
            </a>
          </div>

          {/* ✅ CAMBIADO: Ahora es type="submit" y SIN onClick */}
          <Button type="submit" variant="contained" color="primary" fullWidth>
            Iniciar sesión
          </Button>
        </form>

        <p className="mt-6 text-center text-sm text-gray-500">
          ¿No tienes cuenta?{" "}
          <a href="#" className="text-indigo-600 hover:underline">
            Regístrate
          </a>
        </p>
      </div>
    </div>
  );
};

export default Login;
