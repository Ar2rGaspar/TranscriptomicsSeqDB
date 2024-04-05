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

// core callback function
app.get('/data', async (req, res) => {
  try {
    const searchTerm = req.query.search;
    const selectedType = req.query.type;
    const selectedChromosome = req.query.chromosome;
    const selectedSpeed = req.query.speed;

    let geneResults = [];
    let sampleResults = [];

    // GENE query
    if (selectedChromosome || (!selectedSpeed && (searchTerm || selectedType))) {
      let geneQuery = 'SELECT * FROM gene WHERE ';

      if (searchTerm) {
        geneQuery += `name LIKE '%${searchTerm}%' AND `;
      }

      if (selectedType) {
        geneQuery += `type = '${selectedType}' AND `;
      }

      if (selectedChromosome) {
        geneQuery += `chromosome = '${selectedChromosome}'`;
      } else {
        geneQuery = geneQuery.slice(0, -5);
      }

      geneResults = await poolQuery(geneQuery);
    }

    // SAMPLE query
    if (selectedSpeed || (!selectedChromosome && (searchTerm || selectedType))) {
      let sampleQuery = 'SELECT * FROM sample WHERE ';

      if (searchTerm) {
        sampleQuery += `sample LIKE '%${searchTerm}%' AND `;
      }

      if (selectedType) {
        sampleQuery += `type = '${selectedType}' AND `;
      }

      if (selectedSpeed) {
        sampleQuery += `speed = '${selectedSpeed}'`;
      } else {
        sampleQuery = sampleQuery.slice(0, -5);
      }

      sampleResults = await poolQuery(sampleQuery);
    }

    let combinedResults = [];
    if (selectedChromosome && selectedSpeed) {
      combinedResults = [];
    } else {
      combinedResults = [...geneResults, ...sampleResults];
    }

    res.json(combinedResults);
  } catch (error) {
    console.error('Database query error:', error);
    res.status(500).json({ error: 'Internal server error' });
  }
});

// promisify pool.query
function poolQuery(query) {
  return new Promise((resolve, reject) => {
    pool.query(query, (error, results) => {
      if (error) {
        reject(error);
      } else {
        resolve(results);
      }
    });
  });
}

const port = 3000;
app.listen(port, () => {
  console.log(`Server is running on http://localhost:${port}`);
});