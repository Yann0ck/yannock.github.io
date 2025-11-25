---
layout: splash
title: "Yannock Verne"
permalink: /
excerpt: "Streamer, photographe, auteur ImpGeo et créateur de SubOrbital Records."
header:
  overlay_color: "#000"
  overlay_filter: "0.35"
  overlay_image: "{{ site.random_header_images | sample }}"
  overlay_filter: "0.4"
---
<script>
  document.addEventListener("DOMContentLoaded", function() {
    var images = [
      "/assets/images/backgrounds/bg1.jpg",
      "/assets/images/backgrounds/bg2.jpg",
      "/assets/images/backgrounds/bg3.jpg",
      "/assets/images/backgrounds/bg4.jpg"
    ];
    var chosen = images[Math.floor(Math.random() * images.length)];
    document.body.style.backgroundImage = "url('" + chosen + "')";
  });
</script>
