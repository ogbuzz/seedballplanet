
(function imageLoader(){

	let elSelector = 'data-src',
		observerMargin = "500px 0px", // peut être exprimé en % aussi
		observerRoot = null;


	let	imagesToLoad = document.querySelectorAll('[' + elSelector + ']');

	function changeImage (img, src){ img.setAttribute('src', src); }

	function changeImageBackground (html, src){ html.style.backgroundImage = 'url(' + src + ')'; }

	function loadImage (elem) {
		let that = elem,
			src = encodeURI(that.getAttribute(elSelector).trim()),
			img = new Image();

		img.onload =  function(){
			that.removeAttribute(elSelector);
			that.nodeName === 'IMG' ? changeImage(that, src) : changeImageBackground(that, src);
		};

		img.src = src;
	}

	if ('IntersectionObserver' in window && 'isIntersecting' in window.IntersectionObserverEntry.prototype){

		let imageObserver = new IntersectionObserver(function(entries, observer) {
			entries.forEach(function(entry) {
				if (entry.isIntersecting) {
					let image = entry.target;
					loadImage(image);
					observer.unobserve(image);
				}
			});
			}, {
			root: observerRoot,
			rootMargin: observerMargin
		});

		imagesToLoad.forEach(function(img){imageObserver.observe(img); });

	} else {imagesToLoad.forEach(function(img){loadImage(img); }); }

}());






(function getLegal(){

	let that = document.querySelector('#legalModal'),
		html = document.querySelector('html'),
		thatCloser = that.querySelector('.delete'),
		thatBackground = that.querySelector('.modal-background'),
		thatTitre = that.querySelector('.modal-card-title'),
		thatContenu = that.querySelector('.modal-card-body'),
		selectedEl = "",
		dataLegal = {"internet":"sorry the internet is slow, try again later please ---- désolé l'internet est lent, essayez à nouveau un peu plus tard svp"};


	function readTextFile(file, callback) {
	    let x = new XMLHttpRequest();
	    x.overrideMimeType("application/json");
	    x.open("GET", file, true);
	    x.onreadystatechange = function() {if (x.readyState === 4 && x.status == "200") {callback(x.responseText);} }
	    x.send(null);
	}

	readTextFile("/json/legal.json", function(text){ dataLegal = JSON.parse(text);});


	function showContenu(el){
		let texte = el.getAttribute('data-legal');
		thatTitre.innerHTML = el.innerHTML;
		thatContenu.innerHTML = dataLegal[texte]  || dataLegal["internet"];
	}

	function openThat(e){
		let el = e.target;
		e.preventDefault();
		showContenu(el);
		that.classList.add('is-active');
		html.classList.add('is-clipped');
		if(selectedEl !== el){
			selectedEl && selectedEl.classList.remove('is-active');
			el.classList.add('is-active');
			selectedEl = el;
		}
	}

	function closeThat(){
		that.classList.remove('is-active');
		html.classList.remove('is-clipped');
	}

	thatCloser.addEventListener('click', closeThat, false);
	thatBackground.addEventListener('click', closeThat, false);
	document.querySelectorAll('#legal a').forEach(function(that){that.addEventListener('click', openThat, false);});

}());





(function nav(){

	let nav = window.document.querySelector('nav');

	let controlBurger = (function( ){

		let burger = nav.querySelector('.navbar-burger'),
			menu = nav.querySelector('.navbar-menu'),
			menuIsOpen = false;

		function that (){
			burger.classList.toggle('is-active');
			menu.classList.toggle('is-active');
			menuIsOpen = !menuIsOpen;
		}

		that.close = function(){
			if(menuIsOpen){
				burger.classList.remove('is-active');
				menu.classList.remove('is-active');
				menuIsOpen = false
			}
		};

		that.isBurger = function( that ){ return that === burger || burger.contains(that);  };

		return that;
	});


	let controlNav = (function ( ){
		let scrolled = false,
			position = { now : 0, last : 0 },
			delta = 30,
			minTop = 50,
			animate = false,
			pinned = false;



		function that (){
			if(pinned){
				nav.classList.remove('pin');
				pinned = false;
			}
		}

		that.hide = function(){
			if(!pinned){
				nav.classList.add('pin');
				pinned = true
			}
		};

		that.scrolled = function(){ scrolled = true; };

		that.resetPosition = function(){
			position.last = position.now;
			position.now = window.pageYOffset;
			scrolled = false;
		};

		that.fixPosition = function(){
			position.now = window.pageYOffset;
			position.last = position.now;
			scrolled = false;
			animate = false;
		};

		that.move = function(){
			if( !animate ){
				that();
				animate = true;
			} else {
				that.resetPosition();
				if( position.now < position.last - delta || position.now < minTop){ that();  }
				else if( position.now > position.last + delta ){ that.hide(); }
			}
		};


		that.anim = function(){
			if(scrolled && !that.anim.isAnimating){
				requestAnimationFrame(function(){
					that.move();
					that.anim.isAnimating = false;
					setTimeout(that.anim, 250);
				});
				scrolled = false;
				that.anim.isAnimating = true;
			} else{setTimeout(that.anim, 250); }
		};


		that.controlBurger = function(e){
				let that = controlBurger.isBurger(e.target);
				if(!that){
					controlBurger.close();
					controlNav.fixPosition()
				}else{controlBurger(); }
			};


		that.init = function(){
			that.fixPosition();
			nav.classList.remove('pin');
			pinned = false;
			setTimeout(that.anim, 250);
		};


		return that;
	}());

	controlNav.init();

	document.addEventListener('click', controlNav.controlBurger, false);
	document.addEventListener('scroll', controlNav.scrolled, false);

}());





(function dateShow(){

	let dates = document.querySelectorAll('[datetime]'),
		options = {weekday: 'long', year: 'numeric', month: 'long', day: 'numeric'},
		userLang = document.documentElement.lang || navigator.language || navigator.userLanguage;


	function testDate(that){return that instanceof Date && !isNaN(that); }

	function dateur(that){
		let date = new Date(that.getAttribute('datetime'));
		return testDate(date) === true ? date.toLocaleDateString(userLang, options) : "";
	}

	dates.forEach(function(that){that.innerHTML = dateur(that); });

}());

