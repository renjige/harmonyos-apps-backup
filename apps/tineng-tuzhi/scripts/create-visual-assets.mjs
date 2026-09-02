#!/usr/bin/env node
/** Generate ops-tool ambient PNGs for Gate C (distinct byte sizes). */
import fs from 'fs';
import path from 'path';
import { fileURLToPath } from 'url';

const __dirname = path.dirname(fileURLToPath(import.meta.url));
const MEDIA = path.resolve(__dirname, '../app/entry/src/main/resources/base/media');

async function main() {
  const sharp = (await import('sharp')).default;
  fs.mkdirSync(MEDIA, { recursive: true });

  const heroSvg = `<svg width="1200" height="800" xmlns="http://www.w3.org/2000/svg">
    <defs>
      <linearGradient id="sky" x1="0" y1="0" x2="0" y2="1">
        <stop offset="0%" stop-color="#FFB088"/>
        <stop offset="55%" stop-color="#FF6B35"/>
        <stop offset="100%" stop-color="#1A2332"/>
      </linearGradient>
    </defs>
    <rect width="1200" height="800" fill="url(#sky)"/>
    <ellipse cx="900" cy="180" rx="220" ry="120" fill="#FFFFFF" opacity="0.12"/>
    <path d="M0 520 Q300 480 600 540 T1200 500 L1200 800 L0 800 Z" fill="#1A2332" opacity="0.55"/>
    <rect x="80" y="600" width="180" height="8" rx="4" fill="#FFFFFF" opacity="0.25"/>
    <rect x="80" y="630" width="120" height="8" rx="4" fill="#FFFFFF" opacity="0.18"/>
  </svg>`;

  const ambientSvg = `<svg width="1200" height="600" xmlns="http://www.w3.org/2000/svg">
    <rect width="1200" height="600" fill="#1A2332"/>
    <path d="M60 420 L200 320 L340 380 L480 240 L620 300 L760 180 L920 260 L1100 200" stroke="#FF6B35" stroke-width="6" fill="none" opacity="0.85"/>
    <path d="M60 480 L220 400 L380 440 L520 340 L680 380 L840 280 L1000 320" stroke="#FF9F76" stroke-width="4" fill="none" opacity="0.5"/>
    <circle cx="200" cy="320" r="10" fill="#FFFFFF" opacity="0.9"/>
    <circle cx="760" cy="180" r="8" fill="#FF6B35"/>
    <rect x="0" y="520" width="1200" height="80" fill="#0F1620" opacity="0.6"/>
  </svg>`;

  await sharp(Buffer.from(heroSvg)).png({ compressionLevel: 8 }).toFile(path.join(MEDIA, 'hero_workout.png'));
  await sharp(Buffer.from(ambientSvg)).png({ compressionLevel: 6 }).toFile(path.join(MEDIA, 'ambient_chart.png'));
  console.log('Visual assets OK');
}

main().catch((e) => { console.error(e); process.exit(1); });
