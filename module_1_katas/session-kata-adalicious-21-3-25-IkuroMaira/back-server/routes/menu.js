const express = require('express');
const router = express.Router();
const db = require('../database');

// GET tous les plats du menu
router.get('/', async (req, res) => {
    const result = await db.query('SELECT * FROM plates');
    console.log(result.rows)
    res.json(result.rows);
});

// GET un plat spécifique par ID
router.get('/:id', async (req, res) => {
});

module.exports = router;