const limmaTutorial = document.getElementById('limma-tutorial');
limmaTutorial.addEventListener('click', () => {
    const detailModal = document.createElement('div');
    detailModal.id = "detail-modal";
    detailModal.className = "modal";

    const closeButton = document.createElement('span');
    closeButton.className = "close";
    closeButton.innerHTML = "&times;";
    closeButton.onclick = closeDetailModal;

    const heading = document.createElement("h2");
    heading.textContent = "Como utilizar o limma:";

    const modalContent = document.createElement("div");
    modalContent.className = "modal-content";

    const paragraph = document.createElement("span");
    paragraph.className = "limma-paragraph";
    paragraph.textContent = "Tutorial em construção . . ."

    modalContent.appendChild(heading);
    modalContent.appendChild(paragraph);
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
  });