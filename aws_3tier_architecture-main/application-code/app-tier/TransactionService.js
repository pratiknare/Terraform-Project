const dbcreds = require('./DbConfig');
const mysql = require('mysql');

const con = mysql.createConnection({
    host: dbcreds.DB_HOST,
    user: dbcreds.DB_USER,
    password: dbcreds.DB_PWD,
    database: dbcreds.DB_DATABASE
});

// CONNECT TO DB
con.connect(err => {
    if (err) {
        console.error("DB connection failed:", err);
        return;
    }
    console.log("Connected to database");
});

function addTransaction(amount, desc) {
    return new Promise((resolve, reject) => {
        const query = "INSERT INTO transactions (amount, description) VALUES (?, ?)";
        con.query(query, [amount, desc], function(err) {
            if (err) return reject(err);
            resolve();
        });
    });
}

function getAllTransactions() {
    return new Promise((resolve, reject) => {
        con.query("SELECT * FROM transactions", (err, result) => {
            if (err) return reject(err);
            resolve(result);
        });
    });
}

module.exports = { addTransaction, getAllTransactions };