require('dotenv').config();

const transactionService = require('./TransactionService');
const express = require('express');
const bodyParser = require('body-parser');
const cors = require('cors');

const app = express();
const port = process.env.PORT || 4000;

app.use(bodyParser.urlencoded({ extended: true }));
app.use(bodyParser.json());
app.use(cors());

// Health
app.get('/health', (req,res)=>{
    res.json({status:"active"});
});

// Add
app.post('/transaction', async (req,res)=>{
    try{
        const { amount, desc } = req.body;
        await transactionService.addTransaction(amount, desc);
        res.json({message:"Added successfully"});
    }
    catch(err){
        console.error(err);
        res.status(500).json({error:"DB insert failed"});
    }
});

// Get all
app.get('/transaction', async (req,res)=>{
    try{
        const rows = await transactionService.getAllTransactions();
        res.json(rows);
    }
    catch(err){
        console.error(err);
        res.status(500).json({error:"Fetch failed"});
    }
});

app.listen(port, ()=>{
    console.log(`Server running on ${port}`);
});