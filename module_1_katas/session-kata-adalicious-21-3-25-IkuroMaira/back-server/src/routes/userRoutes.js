const express = require('express');
const router = express.Router();
const userModel = require('../models/userModel');

// Route pour ajouter un utilisateur
router.post('/users', async (req, res) => {
    try {
        const { firstName } = req.body;

        if (!firstName) {
            // TODO: ajouter une validation
        }

        const newUser = await userModel.addUser(firstName);
        res.json(newUser);
    } catch (error) {
        console.log('Erreur lors de l\'ajout de l\'utilisateur', error);
    }
});

module.exports = router;