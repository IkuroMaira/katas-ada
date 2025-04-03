// --------------------------------------------
//    Point d'entrée de mon appli back-end
// --------------------------------------------

// Importer le module Express
const express = require('express'); /* CORS est un mécanisme qui permet aux serveurs de spécifier quels domaines sont autorisés à accéder à leurs ressources.
C'est essentiellement une façon de contourner la politique de même origine de manière contrôlée et sécurisée. */
const cors = require('cors');
const menuRoutes = require('./routes/menuRoutes');
const userRoutes = require('./routes/userRoutes');
const server = express(); // Créer une instance d'application Express
const port = 5002; // Définir le port sur lequel le serveur va écouter
// TODO: mettre le port dans mon .env

// Middleware pour permettre les requêtes CORS (Cross-Origin Resource Sharing)
server.use(cors({
    origin: 'http://localhost:5173' // URL de mon frontend React
}))

server.use(express.json()); // Middleware pour parser le JSON

// Routes
server.use('/menu', menuRoutes);
server.use('/api', userRoutes);

// Créer une route pour l'API
// server.get('/api', (req, res) => {
//     res.json({
//         message: 'Données du serveur Express',
//     });
// });

// Créer une route pour la page d'accueil
server.get('/', (req, res) => {
    res.send('Page Home');
    console.log('Page Home')
})

// Démarrer le serveur
server.listen(port, () => {
    console.log(`Serveur en cours d'éxécution  sur le port ${port}`);
})