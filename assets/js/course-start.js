window.addEventListener('pageshow', event => {
  // Leave section links and restored reading positions to the browser.
  if (event.persisted || location.hash || window.scrollY > 0 ||
      performance.getEntriesByType('navigation')[0]?.type === 'back_forward') return;

  document.querySelector('.course-header').scrollIntoView({behavior: 'instant', block: 'start'});
}, {once: true});
