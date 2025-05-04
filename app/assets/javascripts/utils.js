window.copyLink = async function (link) {
  try {
    // Using the Clipboard API to copy text to the clipboard
    await navigator.clipboard.writeText(link);
    
    alert('Link copied to clipboard!');
  } catch (err) {
    console.error('Failed to copy: ', err);
    alert('Failed to copy the link!');
  }
}