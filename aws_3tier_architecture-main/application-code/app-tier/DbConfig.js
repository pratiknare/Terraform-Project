require('dotenv').config(); // Add this at the top

module.exports = Object.freeze({
    DB_HOST: process.env.DB_HOST,
    DB_USER: process.env.DB_USER,
    DB_PWD: process.env.DB_PASS,
    DB_DATABASE: process.env.DB_NAME
});