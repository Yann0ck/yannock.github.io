---
title: "Yannock Verne"
layout: single
permalink: /
sidebar: false
author_profile: false
toc: false
classes: yv-home wide

---
<div class="yv-hero">
  <!-- Quand ton logo sera prêt, remplace le src par le bon chemin -->
  <img src="/assets/images/logo-yannock.png" alt="Yannock Verne" class="yv-hero__logo">
</div>

<div class="yv-tabs">

  <!-- NAVIGATION ONGLET -->
  <nav class="yv-tabs__nav" aria-label="Sections principales">
    <button class="yv-tab-link is-active" data-tab="about">Qui je suis</button>
    <button class="yv-tab-link" data-tab="logbook">Journal de bord</button>
    <button class="yv-tab-link" data-tab="photos">Photos</button>
    <button class="yv-tab-link" data-tab="stream">Stream</button>
    <button class="yv-tab-link" data-tab="impgeo">Imperial Geographic</button>
    <!-- On préparera SubOrbital plus tard -->
    <!-- <button class="yv-tab-link" data-tab="suborbital">SubOrbital</button> -->
  </nav>

  <!-- ONGLET : QUI JE SUIS -->
  <section id="tab-about" class="yv-tab-panel is-active">
    <h2>Qui je suis</h2>
    <p>
      Joueur passionné, j'explore Star Citizen et ses merveilles sans prétention, appréciant avant tout
      l'univers et le travail des créateurs.
    </p>
    <p>
      Avec Imperial Geographic, je partage des moments de détente et de discussions autour du 'Verse.
      Et quand je ne suis pas en vol, je capture le ciel, les néons, et les silences entre deux quantum
      à travers mes screenshots et projets perso.
    </p>
  </section>

  <!-- ONGLET : JOURNAL DE BORD -->
  <section id="tab-logbook" class="yv-tab-panel">
    <h2>Journal de bord</h2>
    <p class="yv-logbook-intro">
      Quelques fragments de voyage, saisis entre deux sauts quantiques. Des récits RP, des instants
      captés dans le cockpit ou sur le terrain, quand le 'Verse se fait un peu plus proche.
    </p>

    <div class="yv-log-entries">
      {% assign logs = site.logbook | sort: "date" | reverse %}
      {% if logs.size > 0 %}
        {% for entry in logs %}
            <article class="yv-log-entry">
            <h3>{{ entry.title }}</h3>
            <p class="yv-log-meta">
                {{ entry.date | date: "%Y.%m.%d" }}
            </p>

            <p class="yv-log-excerpt">
                {{ entry.excerpt }}
            </p>

            <button class="yv-log-open" data-target="log-{{ entry.slug }}">
                Lire le récit complet
            </button>

            <!-- Contenu complet (Markdown), caché -->
            <div id="log-{{ entry.slug }}" class="yv-log-full" hidden>
                {{ entry.content }}
            </div>
            </article>
        {% endfor %}
      {% else %}
        <p>Aucun log pour le moment. Le premier récit arrive bientôt.</p>
      {% endif %}
    </div>
  </section>

  <!-- ONGLET : PHOTOS -->
  <section id="tab-photos" class="yv-tab-panel">
    <h2>Photos</h2>
    <p>
      Quelques fragments du 'Verse, capturés au fil de mes sessions. Nebuleuses, hangars, lumières
      de ville ou champs de cailloux à miner — c'est ici que tout finit par se retrouver.
    </p>
    <p>
      La galerie complète est accessible sur une page dédiée.
    </p>
    <p>
      <a class="yv-primary-link" href="/photo/">
        Ouvrir les galeries
      </a>
    </p>
  </section>

  <!-- ONGLET : STREAM -->
  <section id="tab-stream" class="yv-tab-panel">
    <h2>Stream</h2>
    <p>
      Je streame principalement Star Citizen, avec une ambiance chill, discussion, et parfois
      quelques galères techniques — le classique du 'Verse.
    </p>
    <p>
      Retrouve-moi sur Twitch :
      <a href="https://twitch.tv/yannock_" target="_blank" rel="noopener">
        twitch.tv/yannock_
      </a>
    </p>
    <p>
      Les alertes, goals et intégrations sont gérés via StreamElements, selon l'humeur et les projets en cours.
    </p>
  </section>

  <!-- ONGLET : IMPERIAL GEOGRAPHIC -->
  <section id="tab-impgeo" class="yv-tab-panel">
    <h2>Imperial Geographic</h2>
    <p>
      Je suis rédacteur exécutif et éditeur au sein d'Imperial Geographic, un magazine in-lore
      dédié à l'exploration du 'Verse, à ses habitants et à ses histoires.
    </p>
    <p>
      Les numéros sont publiés à intervalles réguliers, souvent en lien avec les grands événements
      de Star Citizen : Invictus, IAE, sorties de systèmes, etc.
    </p>
    <p>
      Tu trouveras bientôt ici une sélection de nos publications avec des liens vers les PDF
      et le Community Hub.
    </p>
  </section>

  <!-- ONGLET : SUBORBITAL (placeholder, non utilisé pour l'instant) -->
  <section id="tab-suborbital" class="yv-tab-panel">
    <h2>SubOrbital Records</h2>
    <p>
      SubOrbital est un label musical in-lore en cours de construction. Pour l'instant, ce projet
      vit surtout dans les documents, les sessions de travail et quelques essais sonores.
    </p>
    <p>
      Une vraie page dédiée arrivera plus tard, peut-être sur <code>suborbital.yannock.eu</code>.
    </p>
  </section>

</div>
<div id="yv-log-modal" class="yv-log-modal" aria-hidden="true">
  <div class="yv-log-modal__backdrop" data-log-close></div>
  <div class="yv-log-modal__content" role="dialog" aria-modal="true" aria-label="Récit complet">
    <button class="yv-log-modal__close" type="button" aria-label="Fermer" data-log-close>
      ×
    </button>
    <div class="yv-log-modal__inner"></div>
  </div>
</div>

<script src="{{ '/assets/js/site.js' | relative_url }}"></script>