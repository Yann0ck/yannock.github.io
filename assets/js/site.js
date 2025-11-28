document.addEventListener("DOMContentLoaded", function () {
  const tabLinks = Array.from(document.querySelectorAll(".yv-tab-link"));
  const tabPanels = Array.from(document.querySelectorAll(".yv-tab-panel"));

  if (!tabLinks.length || !tabPanels.length) {
    return; // rien à gérer si pas d'onglets
  }

  function activateTab(tabName) {
    tabLinks.forEach((btn) => {
      const isActive = btn.dataset.tab === tabName;
      btn.classList.toggle("is-active", isActive);
      btn.setAttribute("aria-pressed", isActive ? "true" : "false");
    });

    tabPanels.forEach((panel) => {
      const isActive = panel.id === `tab-${tabName}`;
      panel.classList.toggle("is-active", isActive);
    });
  }

  tabLinks.forEach((btn) => {
    btn.addEventListener("click", () => {
      const tabName = btn.dataset.tab;
      activateTab(tabName);
    });
  });

  // Si aucun onglet n'est marqué actif dans le HTML, on active le premier
  if (!tabLinks.some((b) => b.classList.contains("is-active"))) {
    const firstTab = tabLinks[0].dataset.tab;
    activateTab(firstTab);
  }
});
// ----- MODAL / LIGHTBOX POUR LE JOURNAL DE BORD -----
(function () {
  const modal = document.getElementById("yv-log-modal");
  if (!modal) return;

  const modalInner = modal.querySelector(".yv-log-modal__inner");
  const closeElements = modal.querySelectorAll("[data-log-close]");

  function openModal(html) {
    modalInner.innerHTML = html;
    modal.classList.add("is-open");
    modal.setAttribute("aria-hidden", "false");
    document.body.classList.add("yv-lock-scroll");
  }

  function closeModal() {
    modal.classList.remove("is-open");
    modal.setAttribute("aria-hidden", "true");
    modalInner.innerHTML = "";
    document.body.classList.remove("yv-lock-scroll");
  }

  // Boutons d'ouverture
  document.querySelectorAll(".yv-log-open").forEach((btn) => {
    btn.addEventListener("click", () => {
      const targetId = btn.dataset.target;
      const fullNode = document.getElementById(targetId);
      if (!fullNode) return;
      openModal(fullNode.innerHTML);
    });
  });

  // Fermeture : croix, backdrop, ESC
  closeElements.forEach((el) => {
    el.addEventListener("click", closeModal);
  });

  document.addEventListener("keydown", (e) => {
    if (e.key === "Escape" && modal.classList.contains("is-open")) {
      closeModal();
    }
  });
})();
