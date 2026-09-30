// RC2 Sistemas — site institucional
(function () {
  'use strict';
  var ano = document.getElementById('ano');
  if (ano) ano.textContent = String(new Date().getFullYear());

  // Se a logo carregar, ela assume o lugar do monograma "RC2" e do texto ao
  // lado (a própria logo já traz o nome da empresa). Sem arquivo: mantém o monograma.
  var logo = document.querySelector('.logo');
  var img = logo && logo.querySelector('img');
  if (!img) return;
  function mostrar() { img.style.display = 'block'; logo.classList.add('tem-logo'); }
  if (img.complete && img.naturalWidth > 0) mostrar(); // já veio do cache
  else {
    img.addEventListener('load', mostrar);
    img.addEventListener('error', function () { img.remove(); });
  }
})();
