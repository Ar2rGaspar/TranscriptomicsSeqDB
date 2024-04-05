document.addEventListener('DOMContentLoaded', (event) => {
    const urlParams = new URLSearchParams(window.location.search);
    const searchQuery = urlParams.get('search');
    if (searchQuery) {
        document.getElementById('search-bar').value = searchQuery;
        filterData();
    }
}); 

const searchInput = document.getElementById('search-bar');
const typeSelect = document.querySelector('select[name="type"]');
const chromosomeSelect = document.querySelector('select[name="chromossome"]');
const speedSelect = document.querySelector('select[name="speed"]');
const resultsContainer = document.getElementById('results');

document.getElementById('btn-20-results').addEventListener('click', () => displayResults(currentData, 20));
document.getElementById('btn-100-results').addEventListener('click', () => displayResults(currentData, 100));
document.getElementById('btn-500-results').addEventListener('click', () => displayResults(currentData, 500));
let currentData = [];
let currentPage = 1;

let itemsPerPage = 500; // default

document.getElementById('btn-20-results').addEventListener('click', () => {
  itemsPerPage = 20;
  currentPage = 1;
  displayResults(currentData, itemsPerPage);
});
document.getElementById('btn-100-results').addEventListener('click', () => {
  itemsPerPage = 100;
  currentPage = 1;
  displayResults(currentData, itemsPerPage);
});
document.getElementById('btn-500-results').addEventListener('click', () => {
  itemsPerPage = 500;
  currentPage = 1;
  displayResults(currentData, itemsPerPage);
});

document.getElementById('previous-page').addEventListener('click', () => {
  if (currentPage > 1) {
    currentPage--;
    displayResults(currentData, itemsPerPage);
  }
});

document.getElementById('next-page').addEventListener('click', () => {
  const maxPage = Math.ceil(currentData.length / itemsPerPage);
  if (currentPage < maxPage) {
    currentPage++;
    displayResults(currentData, itemsPerPage);
  }
});

function filterData() {
  currentPage = 1;
  const searchTerm = searchInput.value.toLowerCase();
  const selectedType = typeSelect.value;
  const selectedChromosome = chromosomeSelect.value;
  const selectedSpeed = speedSelect.value;
  let tableToQuery = selectedSpeed ? 'sample' : 'gene';

  fetch(`http://localhost:3000/data?search=${searchTerm}&type=${selectedType}&chromosome=${selectedChromosome}&speed=${selectedSpeed}&table=${tableToQuery}`)
      .then(response => {
          if (!response.ok) {
              throw new Error('Network error');
          }
          return response.json();
      })
      .then(data => {
          currentData = data;
          displayResults(currentData, itemsPerPage);
      })
      .catch(error => {
          console.error('Fetch error:', error);
      });
}

function displayResults(data, limit) {
    resultsContainer.innerHTML = '';
    const startIndex = (currentPage - 1) * limit;
    const endIndex = startIndex + limit;
    const slicedData = data.slice(startIndex, endIndex);
  
    slicedData.forEach(item => {
      const listItem = document.createElement('li');
      listItem.classList.add('list-item');
      let vepVCFString = '';
  
      if (item.hasOwnProperty('name') && item.hasOwnProperty('chromosome') && item.hasOwnProperty('type')) {
        // GENE table
        listItem.textContent = `${item.name}, ${item.feature_id}, ${item.ensembl_id} (Chromosome: ${item.chromosome}, Type: ${item.type}) `;
        vepVCFString += `${item.chromosome}\t${item.start_bp}\t${item.end_bp}\t${item.ensembl_id}\n`;

        const buttonContainer = document.createElement('div');
        buttonContainer.classList.add('button-container');

        const ensbtagButton = document.createElement('button');
        ensbtagButton.textContent = 'Search ENSBTAG on Ensembl';
        ensbtagButton.addEventListener('click', () => {
          window.open(`https://www.ensembl.org/Multi/Search/Results?q=${item.ensembl_id};site=ensembl_all`, '_blank');
        });
        buttonContainer.appendChild(ensbtagButton);

        const vepButton = document.createElement('button');
        vepButton.textContent = 'Queue on VEP';
        vepButton.addEventListener('click', () => {
          sendVEP(vepVCFString);
        });
        buttonContainer.appendChild(vepButton);

        const modalButton = document.createElement('button');
        modalButton.textContent = 'View details';
        modalButton.addEventListener('click', () => {
          const detailModal = document.createElement('div');
          detailModal.id = "detail-modal";
          detailModal.className = "modal";

          const closeButton = document.createElement('span');
          closeButton.className = "close";
          closeButton.innerHTML = "&times;";
          closeButton.onclick = closeDetailModal;

          const heading = document.createElement("h2");
          heading.textContent = "Gene Details";

          const modalContent = document.createElement("div");
          modalContent.className = "modal-content";

          const infoElements = [
            { label: 'Name:', value: item.name },
            { label: 'Ensembl ID:', value: item.ensembl_id },
            { label: 'Type:', value: item.type },
            { label: 'Chromosome:', value: item.chromosome },
            { label: 'Feature ID:', value: item.feature_id },
            { label: 'Feature ID (old):', value: item.old_feature_id },
            { label: 'Base Pair Start:', value: item.start_bp },
            { label: 'Base Pair End:', value: item.end_bp },
            { label: 'WikiGene Name:', value: item.wikigene_name },
            { label: 'WikiGene Description:', value: item.wikigene_description },
            { label: 'Human Ortholog Gene Symbol:', value: item.human_ortholog_gene_symbol },
            { label: 'Human Ortholog Gene Description:', value: item.human_ortholog_gene_description },
            { label: 'Human Ortholog Gene PubMed ID:', value: item.human_ortholog_gene_pubmed_id }
          ];

          modalContent.appendChild(heading);
          infoElements.forEach(info => {
            const infoElement = document.createElement('p');
            infoElement.textContent = `${info.label} ${info.value}`;
            modalContent.appendChild(infoElement);
          });
          modalContent.appendChild(closeButton);
          detailModal.appendChild(modalContent);
          document.body.appendChild(detailModal);

          function closeDetailModal() {
            detailModal.style.display = "none";
          }

          window.addEventListener("click", function (event) {
            if (event.target === detailModal) {
                closeDetailModal();
              }
          })

          detailModal.style.display = "block";
        })
        buttonContainer.appendChild(modalButton);

        listItem.appendChild(buttonContainer);

        
      } else if (item.hasOwnProperty('gene_id') && item.hasOwnProperty('speed') && item.hasOwnProperty('rpkm') && item.hasOwnProperty('total_reads')) {
        // SAMPLE table
        listItem.textContent = `${item.sample}, ${item.gene_id} (Type: ${item.type}, Speed: ${item.speed}, RPKM: ${item.rpkm}, Total reads: ${item.total_reads})`;

        const buttonContainer = document.createElement('div');
        buttonContainer.classList.add('button-container');

        const modalButton = document.createElement('button');
        modalButton.textContent = 'View details';
        modalButton.addEventListener('click', () => {
          const detailModal = document.createElement('div');
          detailModal.id = "detail-modal";
          detailModal.className = "modal";

          const closeButton = document.createElement('span');
          closeButton.className = "close";
          closeButton.innerHTML = "&times;";
          closeButton.onclick = closeDetailModal;

          const heading = document.createElement("h2");
          heading.textContent = "Gene Details";

          const modalContent = document.createElement("div");
          modalContent.className = "modal-content";

          const infoElements = [
            { label: 'Sample:', value: item.sample },
            { label: 'Gene ID:', value: item.gene_id },
            { label: 'Type:', value: item.type },
            { label: 'Speed:', value: item.speed },
            { label: 'RPKM:', value: item.rpkm },
            { label: 'Total Reads:', value: item.total_reads }
          ];

          modalContent.appendChild(heading);
          infoElements.forEach(info => {
            const infoElement = document.createElement('p');
            infoElement.textContent = `${info.label} ${info.value}`;
            modalContent.appendChild(infoElement);
          });
          modalContent.appendChild(closeButton);
          detailModal.appendChild(modalContent);
          document.body.appendChild(detailModal);

          function closeDetailModal() {
            detailModal.style.display = "none";
          }

          window.addEventListener("click", function (event) {
            if (event.target === detailModal) {
                closeDetailModal();
              }
          })

          detailModal.style.display = "block";
        })
        buttonContainer.appendChild(modalButton);

        listItem.appendChild(buttonContainer);

      } else {
        // undefined
        listItem.textContent = 'Unrecognized data format';

      }
  
      resultsContainer.appendChild(listItem);
    });
  }

function sendVEP(vepVCFString) {
  const vepURL = 'http://rest.ensembl.org/vep/bos_taurus/region';
  const variantsArray = vepVCFString.trim().split('\n');

  fetch(vepURL, {
    method: 'POST',
    headers: {
      'Content-Type': 'application/json',
      'Accept': 'application/json'
    },
    body: JSON.stringify({ variants : variantsArray })
  })
  .then(response => response.json())
  .then(data => {
    console.log(data);
  })
  .catch(error => {
    console.error('Error:', error);
  });
}

searchInput.addEventListener('input', () => filterData());
typeSelect.addEventListener('change', () => filterData());
chromosomeSelect.addEventListener('change', () => filterData());
speedSelect.addEventListener('change', () => filterData());

document.querySelector('form').addEventListener('submit', function(event) {
    event.preventDefault();
    filterData();
});