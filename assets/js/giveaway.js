document.addEventListener("DOMContentLoaded", () => {
  const statusEl = document.getElementById("giveaway-status");
  const detailsEl = document.getElementById("giveaway-details");

  const channel = "yannock_";  // ← IMPORTANT !

  const ws = new WebSocket(`wss://realtime.streamelements.com/socket.io/?EIO=3&transport=websocket`);

  let sessionId = null;

  ws.onopen = () => {
    console.log("Connected to StreamElements socket.");
  };

  ws.onmessage = (msg) => {
    const data = msg.data;

    // Step 1 — Get session ID
    if (data.startsWith("40")) {
      const payload = JSON.parse(data.substring(2));
      sessionId = payload.sid;

      // Authenticate anonymously → no token required for giveaway events
      ws.send(`42["authenticate",{"method":"jwt","token":""}]`);
      return;
    }

    // Step 2 — Confirm authentication
    if (data.includes("authenticated")) {
      console.log("Authenticated.");
      // Subscribe to giveaway channel
      ws.send(`42["subscribe","${channel}:giveaway"]`);
      return;
    }

    // Step 3 — Giveaway events
    if (data.startsWith("42")) {
      const parsed = JSON.parse(data.substring(2));
      const event = parsed[0];
      const payload = parsed[1];

      if (!payload) return;

      switch (event) {
        case "event:giveaway:start":
          statusEl.textContent = "🎉 Giveaway en cours !";
          detailsEl.textContent = "Les participants peuvent entrer via le chat Twitch.";
          break;

        case "event:giveaway:end":
          statusEl.textContent = "⏱️ Giveaway terminé.";
          detailsEl.textContent = "Tirage du gagnant en cours…";
          break;

        case "event:giveaway:winner":
          statusEl.textContent = "🏆 Un gagnant a été tiré !";
          detailsEl.textContent = `Gagnant : ${payload.winner}`;
          break;

        default:
          console.log("Autre event :", event, payload);
      }
    }
  };

  ws.onerror = (e) => {
    statusEl.textContent = "❌ Erreur de connexion.";
  };

  ws.onclose = () => {
    statusEl.textContent = "🔌 Déconnecté du serveur.";
  };
});
