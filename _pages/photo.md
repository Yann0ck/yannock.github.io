---
layout: single
classes: wide
title: "Photos"
permalink: /photo/
---
<div class="content-card" markdown="1">

<p class="gallery-subtitle">Screenshots du Verse • Exploration • Moments capturés</p>

<div id="galleries-container" class="galleries-loading">
  <p>⏳ Chargement des galeries...</p>
</div>

</div>

<!-- Modal pour afficher une galerie -->
<div id="gallery-modal" class="gallery-modal">
  <div class="gallery-modal-header">
    <h2 class="gallery-modal-title" id="modal-title"></h2>
    <button class="gallery-close-btn" onclick="closeGalleryModal()">✕ Fermer</button>
  </div>
  <div id="modal-content" class="gallery-modal-grid"></div>
</div>

<!-- PhotoSwipe (Lightbox) -->
<link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/photoswipe/5.3.8/photoswipe.min.css">
<script src="https://cdnjs.cloudflare.com/ajax/libs/photoswipe/5.3.8/umd/photoswipe.umd.min.js"></script>
<script src="https://cdnjs.cloudflare.com/ajax/libs/photoswipe/5.3.8/umd/photoswipe-lightbox.umd.min.js"></script>

<!-- Script de galerie -->
<script src="/assets/js/gallery.js"></script>
