const db = require('../config/database');

// Ajouter le nom de l'utilisateur
const addUser = async (firstName) => {
    try {
        // Ajouter le paramètre firstName à la requête SQL avec $1
        const result = await db.query('INSERT INTO users (name) VALUES ($1);', [firstName]);
        return result.rows[0];
    } catch (error) {
        console.log('Erreur lors de l\'ajout de l\'utilisateur:', error);
    }
}

module.exports = {
    addUser
};
