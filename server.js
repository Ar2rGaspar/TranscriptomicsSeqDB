const express = require('express');
const mysql = require('mysql');
const cors = require('cors');

const pool = mysql.createPool({
  connectionLimit: 10,
  host: 'localhost',
  user: 'root',
  password: 'labic',
  database: 'tseqdb1403'
});

const app = express();
app.use(cors());

app.get('/data', (req, res) => {
  pool.query('SELECT * FROM gene', (error, results) => {
    if (error) {
      console.error('Database query error:', error);
      res.status(500).json({ error: 'Internal server error' });
    } else {
      res.json(results);
    }
  });
});

const port = 3000;
app.listen(port, () => {
  console.log(`Server is running on http://localhost:${port}`);
});