/** Build photo generation manifest from platform runtime JSON */
import fs from 'fs';
import path from 'path';
import { fileURLToPath } from 'url';

const __dirname = path.dirname(fileURLToPath(import.meta.url));
const ROOT = path.resolve(__dirname, '..');
const RUNTIME = path.resolve(ROOT, '../../platform/data/runtime/wenbo-jieqi-shipu');
const OUT = path.join(ROOT, 'store/visual/photo-manifest.json');
const STAGING = path.join(ROOT, 'store/visual/generated');

const PROMPT_PREFIX =
  'Commercial mobile app photoreal editorial food photography for Chinese solar-term seasonal cooking app. ' +
  'Warm orange #E8833A and rice paper #F5F0E8 mood, subtle green accent #3A7D44. ' +
  'NOT UI screenshot, NOT cartoon, NOT 3D, no purple AI glow, no text, no watermark. ';

function recipePrompt(item) {
  const ing = (item.ingredients || []).slice(0, 4).join('、');
  return (
    PROMPT_PREFIX +
    `Scene: finished dish "${item.title}" for ${item.solarTerm} solar term, ${item.effect} nourishment. ` +
    `Ingredients visible: ${ing}. ` +
    'Ceramic bowl or wooden table, soft natural window light, 4:3 food hero shot, appetizing steam optional.'
  );
}

function termPrompt(item) {
  const foods = (item.seasonalFoods || []).slice(0, 4).join('、');
  return (
    PROMPT_PREFIX +
    `Scene: ${item.title} solar term editorial still life — seasonal ingredients ${foods} on rustic table, ` +
    'spring/summer/autumn/winter atmosphere matching term, 1:1 square crop, negative space at top.'
  );
}

function tipPrompt(item) {
  return (
    PROMPT_PREFIX +
    `Scene: gentle wellness food lifestyle for ${item.solarTerm} — light tea, herbs, seasonal produce arrangement, ` +
    'calm editorial 16:9 banner, soft bokeh, health nourishment mood.'
  );
}

const recipes = JSON.parse(fs.readFileSync(path.join(RUNTIME, 'solar-recipes-recipes.json'), 'utf8')).items;
const terms = JSON.parse(fs.readFileSync(path.join(RUNTIME, 'solar-recipes-terms.json'), 'utf8')).items;
const tips = JSON.parse(fs.readFileSync(path.join(RUNTIME, 'solar-recipes-tips.json'), 'utf8')).items;

const items = [];

for (const r of recipes) {
  items.push({
    file: `${r.coverKey}.png`,
    kind: 'recipe',
    title: r.title,
    aspect: '4:3',
    prompt: recipePrompt(r),
  });
}
for (const t of terms) {
  items.push({
    file: `${t.coverKey}.png`,
    kind: 'term',
    title: t.title,
    aspect: '1:1',
    prompt: termPrompt(t),
  });
}
for (const t of tips) {
  items.push({
    file: `${t.coverKey}.png`,
    kind: 'tip',
    title: t.title,
    aspect: '16:9',
    prompt: tipPrompt(t),
  });
}

fs.mkdirSync(STAGING, { recursive: true });
fs.mkdirSync(path.dirname(OUT), { recursive: true });
fs.writeFileSync(OUT, JSON.stringify({ items, staging: STAGING, media: path.join(ROOT, 'app/entry/src/main/resources/base/media') }, null, 2));
console.log('manifest items:', items.length, '→', OUT);
