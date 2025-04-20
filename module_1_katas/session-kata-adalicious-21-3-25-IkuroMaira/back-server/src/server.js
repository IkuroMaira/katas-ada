// --------------------------------------------
//    Point d'entrée de mon appli back-end
// --------------------------------------------

require('dotenv').config();
// Importer le module Express
const express = require('express'); /* CORS est un mécanisme qui permet aux serveurs de spécifier quels domaines sont autorisés à accéder à leurs ressources.
C'est essentiellement une façon de contourner la politique de même origine de manière contrôlée et sécurisée. */
const cors = require('cors');
const menuRoutes = require('./routes/menuRoutes');
const userRoutes = require('./routes/userRoutes');

const server = express(); // Créer une instance d'application Express
const port = process.env.SERVER_PORT; // Définir le port sur lequel le serveur va écouter

// Middleware pour permettre les requêtes CORS (Cross-Origin Resource Sharing)
server.use(cors({
    origin: 'http://localhost:5012' // URL de mon frontend React
}))

server.use(express.json()); // Middleware pour parser le JSON

server.use('/menu', menuRoutes);
server.use('/api', userRoutes);

server.get('/', (req, res) => {
    res.send('Page Home');
    console.log('Page Home')
})

// Démarrer le serveur
server.listen(port, () => {
    console.log(`Serveur en cours d'éxécution  sur le port ${port}`);
})