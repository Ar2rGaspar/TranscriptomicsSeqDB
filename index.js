document.addEventListener('DOMContentLoaded', (event) => {
    const urlParams = new URLSearchParams(window.location.search);
    const searchQuery = urlParams.get('search');
    if (searchQuery) {
        document.getElementById('search-bar').value = searchQuery;
        filterData();
    }
});

const jsonFilePath = 'teste.json';
let jsonData = null;
let filteredData = [];

function fetchJsonData(filePath) {
  return fetch(filePath)
    .then(response => {
      if (!response.ok) {
        throw new Error('Network error');
      }
      return response.json();
    })
    .catch(error => {
      console.error('Fetch error:', error);
    });
}

fetchJsonData(jsonFilePath).then(data => {
  jsonData = data;
  filterData();
});

const searchInput = document.getElementById('search-bar');
const typeSelect = document.querySelector('select[name="type"]');
const chromosomeSelect = document.querySelector('select[name="chromossome"]');
const resultsContainer = document.getElementById('results');

function filterData() {
    const searchTerm = searchInput.value.toLowerCase();
    const selectedType = typeSelect.value;
    const selectedChromosome = chromosomeSelect.value;

    if (jsonData) {
        filteredData = jsonData.gene.filter(gene => {
          return (
            gene.name.toLowerCase().includes(searchTerm) ||
            gene.type.toLowerCase().includes(searchTerm) ||
            gene.chromosome.toLowerCase().includes(searchTerm) ||
            gene.feature_id.toLowerCase().includes(searchTerm) ||
            gene.ensembl_id.toLowerCase().includes(searchTerm)
          ) && (
            selectedType ? gene.type === selectedType : true
          ) && (
            selectedChromosome ? gene.chromosome === selectedChromosome : true
          );
        });
    
        displayResults(filteredData, 5);
    }
}

function displayResults(data, limit) {
  resultsContainer.innerHTML = '';
  const slicedData = data.slice(0, limit);

  slicedData.forEach(gene => {
    const geneElement = document.createElement('li');
    geneElement.textContent = `${gene.name}, ${gene.feature_id}, ${gene.ensembl_id} (Chromosome: ${gene.chromosome}, Type: ${gene.type})`;
    resultsContainer.appendChild(geneElement);
  });
}

searchInput.addEventListener('input', () => filterData());
typeSelect.addEventListener('change', () => filterData());
chromosomeSelect.addEventListener('change', () => filterData());

document.getElementById('btn-5-results').addEventListener('click', () => displayResults(filteredData, 5));
document.getElementById('btn-30-results').addEventListener('click', () => displayResults(filteredData, 30));
document.getElementById('btn-50-results').addEventListener('click', () => displayResults(filteredData, 50));

document.querySelector('form').addEventListener('submit', function(event) {
    event.preventDefault();
    filterData();
});