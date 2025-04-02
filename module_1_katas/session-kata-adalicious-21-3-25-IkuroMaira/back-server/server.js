// --------------------------------------------
    // Point d'entrée de mon appli back-end
// --------------------------------------------

// Importer le module Express
const express = require('express');
/* CORS est un mécanisme qui permet aux serveurs de spécifier quels domaines sont autorisés à accéder à leurs ressources.
C'est essentiellement une façon de contourner la politique de même origine de manière contrôlée et sécurisée. */
const cors = require('cors');
const menuRoutes = require('./routes/menu')
// Créer0 une instance d'application Express
const server = express();
// Définir le port sur lequel le serveur va écouter
const port = 5002;

// Middleware pour permettre les requêtes CORS (Cross-Origin Resource Sharing)
server.use(cors({
    origin: 'http://localhost:5173' // URL de mon frontend React
}))

// Middleware pour parser le JSON
server.use(express.json());

// Routes
server.use('/menu', menuRoutes);

// Créer une route pour l'API
server.get('/api', (req, res) => {
    res.json({
        message: 'Données du serveur Express',
        items: ['Item 1', 'Item 2', 'Item 3']
    });
});

// Créer une route pour la page d'accueil
server.get('/', (req, res) => {
    res.send('Page Home');
    console.log('Page Home')
})

// Démarrer le serveur
server.listen(port, () => {
    console.log(`Serveur en cours d'éxécution  sur le port ${port}`);
})