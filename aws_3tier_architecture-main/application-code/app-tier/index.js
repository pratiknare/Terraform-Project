const transactionService = require('./TransactionService');
const express = require('express');
const bodyParser = require('body-parser');
const cors = require('cors');

const app = express();
const port = 4000;

app.use(bodyParser.urlencoded({ extended: true }));
app.use(bodyParser.json());
app.use(cors());

// Health Check
app.get('/health', (req, res) => {
    res.json({ status: "active", message: "App Tier is healthy" });
});

// Add Transaction
app.post('/transaction', (req, res) => {
    try {
        const { amount, desc } = req.body;
        const success = transactionService.addTransaction(amount, desc);
        if (success === 200) {
            res.status(200).json({ message: 'Added transaction successfully' });
        }
    } catch (err) {
        res.status(500).json({ message: 'Something went wrong', error: err.message });
    }
});

// Get All Transactions
app.get('/transaction', (req, res) => {
    try {
        transactionService.getAllTransactions(function (results) {
            const transactionList = results.map(row => ({
                id: row.id,
                amount: row.amount,
                description: row.description
            }));
            res.status(200).json({ result: transactionList });
        });
    } catch (err) {
        res.status(500).json({ message: "Could not retrieve transactions", error: err.message });
    }
});

app.listen(port, () => {
    console.log(`Backend listening at http://localhost:${port}`);
});