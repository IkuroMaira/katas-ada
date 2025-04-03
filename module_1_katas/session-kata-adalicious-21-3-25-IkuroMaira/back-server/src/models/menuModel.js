const db = require('../config/database');

const MenuModel = {
    // Récupérer tous les plats
    getAllPlates: async () => {
        try {
            const result = await db.query('SELECT * FROM plates');
            return result.rows;
        } catch (error) {
            console.log("Erreur au niveau du modèle", error);
        }
    }
}

module.exports = MenuModel;