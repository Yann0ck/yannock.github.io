/**
 * Système de galeries photo - Yannock Verne
 * Compatible avec Jekyll + Minimal Mistakes
 */

(function () {
  'use strict';

  const GALLERIES_PATH = '/galeries';
  let currentGallery = null;
  let lightbox = null;

  /**
   * Charger l'index des galeries
   */
  async function loadGalleries() {
    const container = document.getElementById('galleries-container');

    if (!container) {
      console.warn('Container de galeries non trouvé');
      return;
    }

    try {
      const response = await fetch(`${GALLERIES_PATH}/galleries-index.json`);

      if (!response.ok) {
        throw new Error(`HTTP ${response.status}: ${response.statusText}`);
      }

      const data = await response.json();
      console.log('galleries-index.json chargé :', data);

      let galleries;

      if (Array.isArray(data)) {
        // 1) JSON = [ {...}, {...} ]
        galleries = data;
      } else if (Array.isArray(data.galleries)) {
        // 2) JSON = { "galleries": [ {...}, {...} ] }
        galleries = data.galleries;
      } else if (Array.isArray(data.galeries)) {
        // 3) JSON = { "galeries": [ {...}, {...} ] }
        galleries = data.galeries;
      } else {
        // 4) JSON = { "avril-2955": {...}, "juin-2955": {...} }
        galleries = Object.values(data);
      }

      displayGalleries(galleries);
    } catch (error) {
      console.error('Erreur chargement galeries:', error);
      container.className = 'galleries-error';
      container.innerHTML = `
        <p>❌ Impossible de charger les galeries</p>
        <p>Assurez-vous d'avoir lancé le script <code>GenerateMiniatures.ps1</code></p>
      `;
    }
  }

  /**
   * Afficher la liste des galeries
   */
  function displayGalleries(galleries) {
    const container = document.getElementById('galleries-container');

    if (!galleries || galleries.length === 0) {
      container.className = 'galleries-error';
      container.innerHTML = '<p>Aucune galerie disponible pour le moment</p>';
      return;
    }

    // Trier par date (plus récent en premier)
    galleries.sort((a, b) => new Date(b.date) - new Date(a.date));

    container.className = 'galleries-grid';
    container.innerHTML = galleries
      .map((gallery) => {
        const coverUrl = `${GALLERIES_PATH}/${gallery.id}/${gallery.coverImage}`;
        const galleryName = formatGalleryName(gallery.nom);

        return `
        <div class="gallery-card" onclick="openGallery('${escapeHtml(
          gallery.id
        )}', '${escapeHtml(gallery.nom)}')">
          <img src="${coverUrl}"
               alt="${escapeHtml(galleryName)}"
               class="gallery-card-image"
               loading="lazy"
               onerror="this.src='data:image/svg+xml,%3Csvg xmlns=%22http://www.w3.org/2000/svg%22 width=%22400%22 height=%22300%22%3E%3Crect fill=%22%23111%22 width=%22400%22 height=%22300%22/%3E%3Ctext x=%2250%25%22 y=%2250%25%22 fill=%22%23666%22 text-anchor=%22middle%22 dy=%22.3em%22%3EImage non disponible%3C/text%3E%3C/svg%3E'">
          <div class="gallery-card-content">
            <h3 class="gallery-card-title">${galleryName}</h3>
            <div class="gallery-card-meta">
              <span class="gallery-card-count">📸 ${
                gallery.imageCount
              } photo${gallery.imageCount > 1 ? 's' : ''}</span>
            </div>
          </div>
        </div>
      `;
      })
      .join('');
  }

  /**
   * Ouvrir une galerie spécifique
   */
  window.openGallery = async function (galleryId, galleryName) {
    try {
      const response = await fetch(`${GALLERIES_PATH}/${galleryId}/index.json`);

      if (!response.ok) {
        throw new Error('Galerie non trouvée');
      }

      const gallery = await response.json();
      currentGallery = { ...gallery, id: galleryId };

      displayGalleryModal(gallery, galleryName);
    } catch (error) {
      console.error('Erreur ouverture galerie:', error);
      alert('Impossible de charger cette galerie. Veuillez réessayer.');
    }
  };

  /**
   * Afficher le modal avec les miniatures
   */
  function displayGalleryModal(gallery, galleryName) {
    const modal = document.getElementById('gallery-modal');
    const title = document.getElementById('modal-title');
    const content = document.getElementById('modal-content');

    if (!modal || !title || !content) {
      console.error('Éléments du modal non trouvés');
      return;
    }

    title.textContent = formatGalleryName(galleryName);

    content.innerHTML = gallery.images
      .map((img, index) => {
        const thumbUrl = `${GALLERIES_PATH}/${currentGallery.id}/${img.thumb}`;
        const fullUrl = `${GALLERIES_PATH}/${currentGallery.id}/${img.original}`;

        return `
        <a href="${fullUrl}"
           class="gallery-thumb"
           data-pswp-src="${fullUrl}">
          <img src="${thumbUrl}"
               alt="Photo ${index + 1} - ${formatGalleryName(galleryName)}"
               loading="lazy"
               onerror="this.parentElement.classList.add('loading')">
        </a>
      `;
      })
      .join('');

    modal.classList.add('active');
    document.body.style.overflow = 'hidden';

    // Prépare les dimensions des images puis initialise PhotoSwipe
    preparePhotoSwipe().catch((err) =>
      console.error('Erreur préparation PhotoSwipe :', err)
    );
  }

  /**
   * Préparer les dimensions des images pour PhotoSwipe
   * (on lit la vraie taille des images plein format puis
   *  on renseigne data-pswp-width / data-pswp-height)
   */
  async function preparePhotoSwipe() {
    // Toujours détruire une éventuelle lightbox précédente
    if (lightbox) {
      lightbox.destroy();
      lightbox = null;
    }

    const anchors = Array.from(
      document.querySelectorAll('#modal-content a.gallery-thumb')
    );

    if (!anchors.length) return;

    await Promise.all(
      anchors.map(
        (a) =>
          new Promise((resolve) => {
            const img = new Image();
            const src = a.getAttribute('data-pswp-src') || a.href;

            img.onload = () => {
              const w = img.naturalWidth || img.width || 1920;
              const h = img.naturalHeight || img.height || 1080;

              a.setAttribute('data-pswp-width', w);
              a.setAttribute('data-pswp-height', h);

              resolve();
            };

            img.onerror = () => {
              // Fallback 16:9 si on n'arrive pas à lire la taille
              a.setAttribute('data-pswp-width', 1920);
              a.setAttribute('data-pswp-height', 1080);
              resolve();
            };

            img.src = src;
          })
      )
    );

    initPhotoSwipe();
  }

  /**
   * Fermer le modal
   */
  window.closeGalleryModal = function () {
    const modal = document.getElementById('gallery-modal');

    if (!modal) return;

    modal.classList.remove('active');
    document.body.style.overflow = '';

    if (lightbox) {
      lightbox.destroy();
      lightbox = null;
    }
  };

  /**
   * Initialiser PhotoSwipe (lightbox)
   */
  function initPhotoSwipe() {
    if (typeof PhotoSwipeLightbox === 'undefined' || typeof PhotoSwipe === 'undefined') {
      console.error('PhotoSwipe non chargé');
      return;
    }

    if (lightbox) {
      lightbox.destroy();
      lightbox = null;
    }

    lightbox = new PhotoSwipeLightbox({
      gallery: '#modal-content',
      children: 'a.gallery-thumb',
      pswpModule: PhotoSwipe,
      bgOpacity: 0.96,
      padding: { top: 32, bottom: 32, left: 24, right: 24 },
      wheelToZoom: true,
      showHideAnimationType: 'zoom'
    });

    lightbox.init();
  }

  /**
   * Utilitaires
   */
  function formatGalleryName(name) {
    if (!name || typeof name !== 'string') return '';
    return name
      .replace(/-/g, ' ')
      .replace(/_/g, ' ')
      .replace(/\s+/g, ' ')
      .trim()
      .replace(/\b\w/g, (l) => l.toUpperCase());
  }

  function escapeHtml(text) {
    if (!text) return '';
    const map = {
      '&': '&amp;',
      '<': '&lt;',
      '>': '&gt;',
      '"': '&quot;',
      "'": '&#039;'
    };
    return text.replace(/[&<>"']/g, (m) => map[m]);
  }

  /**
   * Gestion du clavier
   */
  document.addEventListener('keydown', function (e) {
    const modal = document.getElementById('gallery-modal');

    if (modal && modal.classList.contains('active') && e.key === 'Escape') {
      // Ne fermer que si PhotoSwipe n'est pas ouvert
      if (!document.querySelector('.pswp--open')) {
        closeGalleryModal();
      }
    }
  });

  /**
   * Initialisation au chargement de la page
   */
  if (document.readyState === 'loading') {
    document.addEventListener('DOMContentLoaded', loadGalleries);
  } else {
    loadGalleries();
  }
})();
