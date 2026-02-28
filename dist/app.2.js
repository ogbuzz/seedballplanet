

		//~ <script "burger">

		  document.addEventListener('DOMContentLoaded', () => {
				const burger = document.querySelector('.navbar-burger');
				const menu = document.querySelector('.navbar-menu');

				burger.addEventListener('click', () => {
				  const isActive = burger.classList.toggle('is-active');
				  menu.classList.toggle('is-active', isActive);
				});
		  });



//~ <script "themeToggler">

document.addEventListener("DOMContentLoaded", () => {
	const root = document.documentElement;
	const toggleBtn = document.querySelector(".theme-toggle");
	const sysPrefersDark = matchMedia("(prefers-color-scheme: dark)");


  // 2️⃣ Fonction pour mettre à jour l’emoji selon le thème actif
  const updateIcon = () => {
		toggleBtn.textContent = root.dataset.theme === "dark" ? "☀️" : "🌙";
  };
  updateIcon();

  // 3️⃣ Écoute du clic bouton (thème manuel)
  toggleBtn.addEventListener("click", () => {
		const newTheme = root.dataset.theme === "dark" ? "light" : "dark";
		root.dataset.theme = newTheme;
		localStorage.setItem("theme", newTheme);
		updateIcon();
  });

  // 4️⃣ Écoute des changements du thème système (si aucun choix enregistré)
  sysPrefersDark.addEventListener("change", (event) => {
		const hasManualOverride = localStorage.getItem("theme") !== null;
		if (!hasManualOverride) {
		  root.dataset.theme = event.matches ? "dark" : "light";
		  updateIcon();
		}
  });
});


function resetTheme(){
	localStorage.removeItem("theme");
  // recalcul instantané selon système
	const prefersDark = matchMedia("(prefers-color-scheme: dark)").matches;
	document.documentElement.dataset.theme = prefersDark ? "dark" : "light";
	document.querySelector(".theme-toggle").textContent = prefersDark ? "☀️" : "🌙";
}




//~ <script "bannerControl">


  document.getElementById('close-banner').onclick = function() {
        localStorage.setItem('banner-close', 'true');
        viewBanner();
    };

// Synchronisation banner multi‑onglets
window.addEventListener('storage', e => {
  // e.key === null → localStorage.clear()
  if (e.key === 'banner-close' || e.key === null) {
    viewBanner();
  }
});



// Tooltip clic mobile pour items désactivés
document.querySelectorAll('.navbar-item.is-disabled').forEach(item => {
  item.addEventListener('click', e => {
    e.preventDefault();
    item.classList.toggle('is-tooltip-active');
    setTimeout(() => item.classList.remove('is-tooltip-active'), 2000);
  });
});


