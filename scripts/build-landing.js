const fs = require('fs');
const path = require('path');
const { execSync } = require('child_process');

// Build landing page
console.log('Building landing page...');
execSync('cd landing && npm install && npm run build', { stdio: 'inherit' });

// Copy Flutter app if available
const flutterSrc = path.join(__dirname, '..', 'build', 'web');
const flutterDst = path.join(__dirname, '..', 'landing', 'dist', 'app');

if (fs.existsSync(flutterSrc)) {
  console.log('Copying Flutter app to /app...');
  fs.mkdirSync(flutterDst, { recursive: true });

  function copyDir(src, dst) {
    fs.readdirSync(src).forEach((item) => {
      const srcPath = path.join(src, item);
      const dstPath = path.join(dst, item);
      const stat = fs.statSync(srcPath);
      if (stat.isDirectory()) {
        fs.mkdirSync(dstPath, { recursive: true });
        copyDir(srcPath, dstPath);
      } else {
        fs.copyFileSync(srcPath, dstPath);
      }
    });
  }

  copyDir(flutterSrc, flutterDst);
  console.log('Flutter app copied successfully.');
} else {
  console.log('No Flutter build found at build/web — skipping.');
}
