import { spawnSync } from 'child_process';
import fs from 'fs';
import path from 'path';
import { fileURLToPath } from 'url';

const dir = path.dirname(fileURLToPath(import.meta.url));
const ps1 = path.join(dir, 'render_logo.ps1');
const r = spawnSync(
  'powershell',
  ['-NoProfile', '-ExecutionPolicy', 'Bypass', '-File', ps1],
  { stdio: 'inherit', windowsHide: true },
);
if (r.status === 0) process.exit(0);

// Minimal fallback: write SVG note; agent should GenerateImage preview-1024.png
const readme = path.join(dir, 'README.md');
if (!fs.existsSync(path.join(dir, 'preview-1024.png'))) {
  fs.writeFileSync(
    readme,
    '# Logo\n\nRun GenerateImage or ImageMagick on symbol.svg → preview-1024.png, foreground.png, background.png\n',
  );
}
process.exit(r.status ?? 1);
