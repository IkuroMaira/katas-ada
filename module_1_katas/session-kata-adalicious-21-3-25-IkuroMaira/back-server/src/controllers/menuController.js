const MenuModel = require('../models/menuModel');

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
    },

    getPlateById: async (req, res) => {
        try {
            const id = parseInt(req.params.id);

            if (isNaN(id)) {
                console.log("Id invalide");
            }

            const plate = await MenuModel.getPlateById(id);

            if (!plate) {
                console.log(`Le plat avec l'ID ${id} n'est pas trouvé`);
            }

            res.json(plate);
        } catch (error) {
            console.log("Erreur lors de la récupération du plat", error);
        }
    }
}

module.exports = MenuController;