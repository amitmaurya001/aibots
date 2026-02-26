// Set a global flag so the template can verify we actually executed.
window.__APP_JS_LOADED__ = true;

document.addEventListener('DOMContentLoaded', function () {
  const btn = document.getElementById('demo-btn');
  if (btn) {
    btn.addEventListener('click', () => alert('Hello from app.js!'));
  }
});
