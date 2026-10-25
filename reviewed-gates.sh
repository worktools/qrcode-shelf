set -euo pipefail
export VITE_BASE_URL=./
# Original: Validate Calcit snapshot and types
set -euo pipefail
test -f calcit.cirru
test -f deps.cirru
test ! -e compact.cirru
test ! -e package.cirru
calcit calcit.cirru --check-only --all-defs
calcit calcit.cirru fix --workflow strict --verify
calcit calcit.cirru --check-only \
  --ns app.comp.container --ns app.comp.barcode --ns app.comp.qrcode \
  --ns app.config --ns app.main --ns app.schema --ns app.updater \
  --summary-only --format json
yarn build
node --test scripts/qrcode-regression.test.mjs
