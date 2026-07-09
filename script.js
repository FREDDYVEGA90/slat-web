/* =========================================================
   SLAT - interacciones de la landing
   ========================================================= */
(function () {
  "use strict";

  var reduceMotion = window.matchMedia("(prefers-reduced-motion: reduce)").matches;
  var WA_NUMBER = "593986411498"; // 0986411498 -> Ecuador +593

  /* ---------- Año en footer ---------- */
  var yearEl = document.getElementById("year");
  if (yearEl) yearEl.textContent = new Date().getFullYear();

  /* ---------- Hero: detener ruta GPS (SMIL) si hay movimiento reducido ---------- */
  if (reduceMotion) {
    document.querySelectorAll(".route-motion").forEach(function (el) {
      el.setAttribute("begin", "indefinite");
    });
  }

  /* ---------- Header: estado al hacer scroll ---------- */
  var header = document.getElementById("header");
  function onScroll() {
    if (window.scrollY > 8) header.classList.add("scrolled");
    else header.classList.remove("scrolled");
  }
  onScroll();
  window.addEventListener("scroll", onScroll, { passive: true });

  /* ---------- Nav móvil ---------- */
  var toggle = document.getElementById("navToggle");
  var nav = document.getElementById("nav");
  if (toggle && nav) {
    toggle.addEventListener("click", function () {
      var open = nav.classList.toggle("open");
      toggle.setAttribute("aria-expanded", open ? "true" : "false");
      toggle.setAttribute("aria-label", open ? "Cerrar menú" : "Abrir menú");
    });
    nav.addEventListener("click", function (e) {
      if (e.target.tagName === "A") {
        nav.classList.remove("open");
        toggle.setAttribute("aria-expanded", "false");
      }
    });
  }

  /* ---------- Reveal on-scroll (IntersectionObserver) ---------- */
  var reveals = document.querySelectorAll(".reveal");
  if (reduceMotion || !("IntersectionObserver" in window)) {
    reveals.forEach(function (el) { el.classList.add("in"); });
  } else {
    var io = new IntersectionObserver(function (entries, obs) {
      entries.forEach(function (entry) {
        if (entry.isIntersecting) {
          entry.target.classList.add("in");
          obs.unobserve(entry.target);
        }
      });
    }, { threshold: 0.15, rootMargin: "0px 0px -8% 0px" });

    // Stagger suave por sección
    reveals.forEach(function (el, i) {
      el.style.transitionDelay = (i % 4) * 70 + "ms";
      io.observe(el);
    });
  }

  /* ---------- Contadores animados ---------- */
  var counters = document.querySelectorAll(".stat-num[data-count]");
  function animateCount(el) {
    var target = parseInt(el.getAttribute("data-count"), 10);
    var prefix = el.getAttribute("data-prefix") || "";
    var suffix = el.getAttribute("data-suffix") || "";
    if (reduceMotion) { el.textContent = prefix + target + suffix; return; }
    var start = 0, dur = 1100, t0 = null;
    function tick(ts) {
      if (!t0) t0 = ts;
      var p = Math.min((ts - t0) / dur, 1);
      var eased = 1 - Math.pow(1 - p, 3);
      el.textContent = prefix + Math.round(start + (target - start) * eased) + suffix;
      if (p < 1) requestAnimationFrame(tick);
    }
    requestAnimationFrame(tick);
  }
  if (counters.length) {
    if (reduceMotion || !("IntersectionObserver" in window)) {
      counters.forEach(animateCount);
    } else {
      var cio = new IntersectionObserver(function (entries, obs) {
        entries.forEach(function (entry) {
          if (entry.isIntersecting) { animateCount(entry.target); obs.unobserve(entry.target); }
        });
      }, { threshold: 0.6 });
      counters.forEach(function (el) { cio.observe(el); });
    }
  }

  /* ---------- Fallback de imágenes (evita íconos rotos) ---------- */
  var gradients = {
    truck:  "linear-gradient(135deg,#142c5e,#081633)",
    fleet:  "linear-gradient(135deg,#1d3d7a,#0d2149)",
    camaron:"linear-gradient(135deg,#0d2149,#142c5e)",
    banano: "linear-gradient(135deg,#142c5e,#0d2149)",
    cacao:  "linear-gradient(135deg,#081633,#142c5e)"
  };
  document.querySelectorAll("img[data-fallback]").forEach(function (img) {
    img.addEventListener("error", function () {
      var key = img.getAttribute("data-fallback");
      var parent = img.parentElement;
      img.style.display = "none";
      // Capa de respaldo con degradado de marca
      var bg = document.createElement("div");
      bg.setAttribute("aria-hidden", "true");
      bg.style.cssText =
        "position:absolute;inset:0;background:" + (gradients[key] || gradients.truck) + ";";
      // Para contenedores que no son absolute-positioned, cubrir el hueco
      if (parent && getComputedStyle(parent).position === "static") {
        parent.style.position = "relative";
      }
      if (img.closest(".why-media")) {
        bg.style.borderRadius = "22px";
        bg.style.minHeight = "320px";
      }
      parent.insertBefore(bg, img);
    }, { once: true });
  });

  /* ---------- Formulario -> WhatsApp ---------- */
  var form = document.getElementById("serviceForm");
  if (form) {
    var note = document.getElementById("formNote");
    var nombre = document.getElementById("nombre");

    function setInvalid(field, msg) {
      var wrap = field.closest(".field");
      wrap.classList.add("invalid");
      var err = wrap.querySelector(".err");
      if (err) err.textContent = msg || "";
    }
    function clearInvalid(field) {
      var wrap = field.closest(".field");
      wrap.classList.remove("invalid");
      var err = wrap.querySelector(".err");
      if (err) err.textContent = "";
    }
    nombre.addEventListener("input", function () { if (nombre.value.trim()) clearInvalid(nombre); });

    form.addEventListener("submit", function (e) {
      e.preventDefault();

      if (!nombre.value.trim()) {
        setInvalid(nombre, "Escribe tu nombre para poder responderte.");
        nombre.focus();
        return;
      }

      var v = function (id) { var el = document.getElementById(id); return el ? el.value.trim() : ""; };
      var lines = [
        "Hola SLAT, quiero solicitar un servicio de transporte.",
        "",
        "Nombre: " + v("nombre"),
        v("empresa") ? "Empresa: " + v("empresa") : "",
        "Tipo de carga: " + v("carga"),
        "Contenedor: " + v("contenedor"),
        v("origen") ? "Origen: " + v("origen") : "",
        v("destino") ? "Destino/puerto: " + v("destino") : "",
        v("mensaje") ? "Detalle: " + v("mensaje") : ""
      ].filter(Boolean);

      var url = "https://wa.me/" + WA_NUMBER + "?text=" + encodeURIComponent(lines.join("\n"));

      if (note) note.textContent = "Abriendo WhatsApp con tu solicitud...";
      window.open(url, "_blank", "noopener");
    });
  }
})();
