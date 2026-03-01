require('dotenv').config();

const transactionService = require('./TransactionService');
const express = require('express');
const bodyParser = require('body-parser');
const cors = require('cors');

const app = express();
const port = process.env.PORT || 4000;
const host = process.env.HOST || "0.0.0.0";   // IMPORTANT for Load Balancer

app.use(bodyParser.urlencoded({ extended: true }));
app.use(bodyParser.json());
app.use(cors());

// Health Check Route
app.get('/health', (req, res) => {
    res.json({ status: "active" });
});

// Add Transaction
app.post('/transaction', async (req, res) => {
    try {
        const { amount, desc } = req.body;
        await transactionService.addTransaction(amount, desc);
        res.json({ message: "Added successfully" });
    } catch (err) {
        console.error(err);
        res.status(500).json({ error: "DB insert failed" });
    }
});

// Get All Transactions
app.get('/transaction', async (req, res) => {
    try {
        const rows = await transactionService.getAllTransactions();
        res.json(rows);
    } catch (err) {
        console.error(err);
        res.status(500).json({ error: "Fetch failed" });
    }
});

// START SERVER  ✅ FIXED
app.listen(port, host, () => {
    console.log(`Server running on http://${host}:${port}`);
});