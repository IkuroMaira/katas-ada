const { Pool } = require('pg');
const {text} = require("express");
require('dotenv').config();

const pool = new Pool({
    connectionString: process.env.DATABASE_URL,
    ssl: {
        rejectUnauthorized: false
    }
})

module.exports = {
    query: (text, params) => pool.query(text, params),
}