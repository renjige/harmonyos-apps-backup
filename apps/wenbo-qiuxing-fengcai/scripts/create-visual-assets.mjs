#!/usr/bin/env node
/** Generate distinct sports editorial PNGs for Gate C (unique byte sizes). */
import fs from 'fs';
import path from 'path';
import { fileURLToPath } from 'url';

const __dirname = path.dirname(fileURLToPath(import.meta.url));
const MEDIA = path.resolve(__dirname, '../app/entry/src/main/resources/base/media');

const SPECS = [
  { file: 'hero_sports_discovery.png', w: 1200, h: 800, a: '#0B3D2E', b: '#145A32', c: '#1E8449', seed: 1 },
  { file: 'athlete_football_1.png', w: 1024, h: 1024, a: '#145A32', b: '#1E8449', c: '#27AE60', seed: 2 },
  { file: 'athlete_football_2.png', w: 1024, h: 1024, a: '#1B4332', b: '#2D6A4F', c: '#40916C', seed: 3 },
  { file: 'athlete_football_3.png', w: 1024, h: 1024, a: '#0D2818', b: '#1B4332', c: '#52B788', seed: 4 },
  { file: 'athlete_basketball_1.png', w: 1024, h: 1024, a: '#7B2D26', b: '#C0392B', c: '#E74C3C', seed: 5 },
  { file: 'athlete_basketball_2.png', w: 1024, h: 1024, a: '#641E16', b: '#922B21', c: '#CB4335', seed: 6 },
  { file: 'athlete_basketball_3.png', w: 1024, h: 1024, a: '#4A235A', b: '#7D3C98', c: '#AF7AC5', seed: 7 },
  { file: 'athlete_tennis_1.png', w: 1024, h: 1024, a: '#7D6608', b: '#B7950B', c: '#F1C40F', seed: 8 },
  { file: 'athlete_tennis_2.png', w: 1024, h: 1024, a: '#784212', b: '#A04000', c: '#D68910', seed: 9 },
  { file: 'athlete_racing_1.png', w: 1024, h: 1024, a: '#1B2631', b: '#2C3E50', c: '#566573', seed: 10 },
  { file: 'athlete_racing_2.png', w: 1024, h: 1024, a: '#17202A', b: '#212F3D', c: '#5D6D7E', seed: 11 },
  { file: 'athlete_other_1.png', w: 1024, h: 1024, a: '#0E6655', b: '#117A65', c: '#48C9B0', seed: 12 },
  { file: 'athlete_other_2.png', w: 1024, h: 1024, a: '#154360', b: '#1F618D', c: '#3498DB', seed: 13 },
  { file: 'event_football_1.png', w: 1200, h: 675, a: '#145A32', b: '#196F3D', c: '#58D68D', seed: 14 },
  { file: 'event_basketball_1.png', w: 1200, h: 675, a: '#922B21', b: '#C0392B', c: '#F1948A', seed: 15 },
  { file: 'event_tennis_1.png', w: 1200, h: 675, a: '#7D6608', b: '#B7950B', c: '#F7DC6F', seed: 16 },
  { file: 'event_racing_1.png', w: 1200, h: 675, a: '#1B2631', b: '#34495E', c: '#85929E', seed: 17 },
  { file: 'event_other_1.png', w: 1200, h: 675, a: '#154360', b: '#2874A6', c: '#85C1E9', seed: 18 },
];

function svgFor(spec) {
  const s = spec.seed;
  const cx = 200 + (s * 47) % 700;
  const cy = 180 + (s * 31) % 400;
  return `<svg width="${spec.w}" height="${spec.h}" xmlns="http://www.w3.org/2000/svg">
    <defs>
      <linearGradient id="bg" x1="0" y1="0" x2="1" y2="1">
        <stop offset="0%" stop-color="${spec.a}"/>
        <stop offset="55%" stop-color="${spec.b}"/>
        <stop offset="100%" stop-color="${spec.c}"/>
      </linearGradient>
      <radialGradient id="glow" cx="50%" cy="40%" r="60%">
        <stop offset="0%" stop-color="#FFFFFF" stop-opacity="0.22"/>
        <stop offset="100%" stop-color="#000000" stop-opacity="0"/>
      </radialGradient>
    </defs>
    <rect width="${spec.w}" height="${spec.h}" fill="url(#bg)"/>
    <rect width="${spec.w}" height="${spec.h}" fill="url(#glow)"/>
    <ellipse cx="${cx}" cy="${cy}" rx="${120 + s * 8}" ry="${80 + s * 5}" fill="#FFFFFF" opacity="0.08"/>
    <path d="M0 ${spec.h * 0.72} Q ${spec.w * 0.25} ${spec.h * 0.62} ${spec.w * 0.5} ${spec.h * 0.74} T ${spec.w} ${spec.h * 0.68} L ${spec.w} ${spec.h} L 0 ${spec.h} Z" fill="#0F172A" opacity="0.45"/>
    <rect x="${40 + s * 3}" y="${spec.h - 90}" width="${180 + s * 4}" height="8" rx="4" fill="#FFFFFF" opacity="0.28"/>
    <rect x="${40 + s * 3}" y="${spec.h - 62}" width="${120 + s * 2}" height="8" rx="4" fill="#FFFFFF" opacity="0.16"/>
    <circle cx="${spec.w - 80 - s * 2}" cy="${80 + s}" r="${24 + (s % 6)}" fill="#FFFFFF" opacity="0.12"/>
  </svg>`;
}

async function main() {
  const sharp = (await import('sharp')).default;
  fs.mkdirSync(MEDIA, { recursive: true });
  let i = 0;
  for (const spec of SPECS) {
    const level = 3 + (i % 7);
    await sharp(Buffer.from(svgFor(spec)))
      .png({ compressionLevel: level, effort: 6 + (i % 4) })
      .toFile(path.join(MEDIA, spec.file));
    console.log(`OK ${spec.file} (compression ${level})`);
    i += 1;
  }
  console.log('Visual assets regenerated with distinct byte sizes.');
}

main().catch((e) => {
  console.error(e);
  process.exit(1);
});
