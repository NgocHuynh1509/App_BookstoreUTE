function normalizeDriveUrl(url) {
  if (!url) return url;
  const match = url.match(/\/d\/(.+?)\//) || url.match(/[?&]id=([^&]+)/);
  if (match && match[1]) {
    return `https://drive.google.com/uc?export=download&id=${match[1]}`;
  }
  return url;
}

const input = process.argv[2];
if (!input) {
  console.log("Usage: node scripts/preview-smoke.js <google_drive_or_pdf_url>");
  process.exit(0);
}

const normalized = normalizeDriveUrl(input.trim());
const isPdfHint = normalized.toLowerCase().includes(".pdf") || normalized.includes("uc?export=download");

console.log("Normalized:", normalized);
console.log("Looks like PDF:", isPdfHint ? "yes" : "unknown");

