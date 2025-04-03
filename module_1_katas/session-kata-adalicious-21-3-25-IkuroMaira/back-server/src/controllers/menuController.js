const MenuModel = require('../models/menuModel');
const db = require("../config/database");

const MenuController = {
    // Récupérer tous les plats
    getAllPlates: async (req, res) => {
        try {
            const menuPlates = await MenuModel.getAllPlates();
            // Pour renvoyer les données au client
            res.json(menuPlates);
        } catch (error) {
            console.log("Erreur lors de la récupération du menu", error);
        }
    }
}

module.exports = MenuController;