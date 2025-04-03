const db = require('../config/database');

const MenuModel = {
    // TODO: mettre en place un CRUD

    // Récupérer tous les plats
    getAllPlates: async () => {
        try {
            const result = await db.query('SELECT * FROM plates');
            return result.rows;
        } catch (error) {
            console.log("Erreur au niveau du modèle", error);
        }
    },

    // Récupérer un plat sélectionné
    getPlateById: async (id) => {
        try {
            const result = await db.query('SELECT id, name, price FROM plates WHERE id=($1);', [id]);
            return result.rows
        } catch (error) {
            console.log("Erreur lors de la récupération du plat", error)
        }
    }
}

module.exports = MenuModel;