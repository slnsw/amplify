(function () {
  function initInstitutionCollectionDropdowns() {
    const form = document.getElementById("report-filter-form");
    if (!form) return;

    const collectionData = JSON.parse(form.dataset.collectionData || "{}");

    const institutionSelect = form.querySelector('[data-role="institution"]');
    const collectionSelect = form.querySelector('[data-role="collection"]');

    if (!institutionSelect || !collectionSelect) return;

    institutionSelect.addEventListener("change", () => {
      const selectedId = institutionSelect.value;
      const collections = collectionData[selectedId] || [];

      collectionSelect.innerHTML = '<option value="">Select a collection</option>';

      collections.forEach(c => {
        const option = document.createElement("option");
        option.value = c.id;
        option.textContent = c.name;
        collectionSelect.appendChild(option);
      });
    });
  }

  document.addEventListener("DOMContentLoaded", initInstitutionCollectionDropdowns);
})();


window.copyLink = function (link) {
  const tempInput = document.createElement('input');
  document.body.appendChild(tempInput);
  tempInput.value = link;
  tempInput.select();
  document.execCommand('copy');
  document.body.removeChild(tempInput);
  alert('Link copied to clipboard!');
}
