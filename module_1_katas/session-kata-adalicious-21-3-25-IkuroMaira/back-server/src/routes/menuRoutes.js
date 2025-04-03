const express = require('express');
const router = express.Router();
const MenuController = require('../controllers/menuController');

router.get('/', MenuController.getAllPlates);

// TODO: GET un plat spécifique par ID

module.exports = router;