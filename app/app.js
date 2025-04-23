const http = require("http");

const server = http.createServer((req, res) => {
  res.end("Hola desde Elastic Beanstalk!");
});

const PORT = process.env.PORT || 3000;
server.listen(PORT, () => {
  console.log(`Servidor escuchando en el puerto ${PORT}`);
});
