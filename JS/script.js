document.addEventListener("DOMContentLoaded", () => {
  const toggle = document.querySelector(".nav-toggle");
  const nav = document.querySelector(".site-nav");

  if (toggle && nav) {
    toggle.addEventListener("click", () => {
      const expanded = nav.classList.toggle("is-open");
      toggle.setAttribute("aria-expanded", String(expanded));
    });
  }

  const year = document.getElementById("year");
  if (year) {
    year.textContent = new Date().getFullYear();
  }

  const form = document.querySelector(".contact-form");
  if (form) {
    form.addEventListener("submit", (event) => {
      event.preventDefault();
      const button = form.querySelector("button[type='submit']");
      if (button) {
        button.textContent = "Message sent";
      }
      form.reset();
    });
  }

});
