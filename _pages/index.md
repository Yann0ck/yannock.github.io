---
layout: single
title: "Yannock Verne"
permalink: /
classes: wide
excerpt: "Streamer, photographe, auteur ImpGeo et créateur de SubOrbital Records."
---

<style>
/* Fond plein écran */
body {
  background-color: #000;
  background-position: center center;
  background-repeat: no-repeat;
  background-attachment: fixed;
  background-size: cover;
}

/* Cadre centré */
.page {
  display: flex;
  justify-content: center;
}

.page__inner {
  max-width: 1100px; /* largeur du cadre */
  width: 100%;
}

/* Bloc blanc pour le contenu */
.page__content {
  background: rgba(255, 255, 255, 0.95);
  padding: 2rem;
  border-radius: 12px;
  box-shadow: 0 4px 24px rgba(0, 0, 0, 0.35);
}
</style>

<script>
  document.addEventListener("DOMContentLoaded", function() {
    var images = [
      "/assets/images/backgrounds/bg1.png",
      "/assets/images/backgrounds/bg2.png",
      "/assets/images/backgrounds/bg3.png",
      "/assets/images/backgrounds/bg4.png"
    ];
    var chosen = images[Math.floor(Math.random() * images.length)];
    document.body.style.backgroundImage = "url('" + chosen + "')";
  });
</script>
