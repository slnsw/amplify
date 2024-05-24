window.copyLink = function (link) {
  const tempInput = document.createElement('input');
  document.body.appendChild(tempInput);
  tempInput.value = link;
  tempInput.select();
  document.execCommand('copy');
  document.body.removeChild(tempInput);
  alert('Link copied to clipboard!');
}
