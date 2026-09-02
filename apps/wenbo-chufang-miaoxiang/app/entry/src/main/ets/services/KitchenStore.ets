import { KitchenListItem, KitchenStats, Recipe, RecipeMatch } from '../models/KitchenModels'
import { KitchenRecipeData } from './KitchenRecipeData'

const KEY_FAVORITES = 'kitchenFavoriteIds'
const KEY_COMPLETED = 'kitchenCompletedIds'
const KEY_HISTORY = 'kitchenHistoryIds'
const KEY_LIST = 'kitchenListItems'

export class KitchenStore {
  static allRecipes(): Recipe[] {
    return KitchenRecipeData.recipes()
  }

  static featured(): Recipe[] {
    const source = KitchenRecipeData.recipes()
    const out: Recipe[] = []
    for (const item of source) {
      if (item.id === 'tomato-egg-noodles' || item.id === 'mushroom-tofu-soup' ||
        item.id === 'light-chicken-salad' || item.id === 'egg-fried-rice') {
        out.push(item)
      }
    }
    return out
  }

  static byCategory(category: string): Recipe[] {
    const out: Recipe[] = []
    for (const item of KitchenRecipeData.recipes()) {
      if (category === '全部' || item.category === category || item.meal === category) {
        out.push(item)
      }
    }
    return out
  }

  static search(query: string): Recipe[] {
    const q = query.trim()
    const out: Recipe[] = []
    if (q.length === 0) return out
    for (const item of KitchenRecipeData.recipes()) {
      if (KitchenStore.recipeContains(item, q)) {
        out.push(item)
      }
    }
    return out
  }

  static findRecipe(id: string): Recipe {
    for (const item of KitchenRecipeData.recipes()) {
      if (item.id === id) return item
    }
    return KitchenRecipeData.recipes()[0]
  }

  static toggleFavorite(id: string): boolean {
    const next = KitchenStore.toggleCsv(KEY_FAVORITES, id)
    AppStorage.setOrCreate('kitchenFavoritePulse', `${Date.now()}`)
    return next
  }

  static isFavorite(id: string): boolean {
    return KitchenStore.hasInCsv(KEY_FAVORITES, id)
  }

  static favoriteRecipes(filter: string): Recipe[] {
    const out: Recipe[] = []
    for (const item of KitchenRecipeData.recipes()) {
      if (KitchenStore.isFavorite(item.id) && (filter === '全部' || item.category === filter || item.meal === filter)) {
        out.push(item)
      }
    }
    return out
  }

  static toggleCompletedRecipe(id: string): boolean {
    return KitchenStore.toggleCsv(KEY_COMPLETED, id)
  }

  static isRecipeCompleted(id: string): boolean {
    return KitchenStore.hasInCsv(KEY_COMPLETED, id)
  }

  static addHistory(id: string): void {
    const raw = AppStorage.get<string>(KEY_HISTORY) ?? ''
    const parts = KitchenStore.csvParts(raw)
    const next: string[] = []
    next.push(id)
    for (const p of parts) {
      if (p !== id && next.length < 12) next.push(p)
    }
    AppStorage.setOrCreate(KEY_HISTORY, next.join(','))
  }

  static historyRecipes(): Recipe[] {
    const out: Recipe[] = []
    for (const id of KitchenStore.csvParts(AppStorage.get<string>(KEY_HISTORY) ?? '')) {
      out.push(KitchenStore.findRecipe(id))
    }
    return out
  }

  static matches(ingredients: string[]): RecipeMatch[] {
    const out: RecipeMatch[] = []
    for (const recipe of KitchenRecipeData.recipes()) {
      const matched: string[] = []
      for (const selected of ingredients) {
        if (KitchenStore.recipeContains(recipe, selected)) {
          matched.push(selected)
        }
      }
      if (matched.length > 0) {
        const reason = matched.length >= 2 ? '家里已有食材覆盖度高，步骤也不复杂。' : '用其中一种食材就能快速展开，适合临时加一道菜。'
        out.push(new RecipeMatch(recipe, matched, reason))
      }
    }
    out.sort((a: RecipeMatch, b: RecipeMatch) => b.matchedIngredients.length - a.matchedIngredients.length)
    const limited: RecipeMatch[] = []
    for (const item of out) {
      if (limited.length < 8) limited.push(item)
    }
    return limited
  }

  static listItems(): KitchenListItem[] {
    const raw = AppStorage.get<string>(KEY_LIST) ?? ''
    const out: KitchenListItem[] = []
    if (raw.length === 0) return out
    for (const row of raw.split(';;')) {
      const parts = row.split('|')
      if (parts.length >= 4) {
        out.push(new KitchenListItem(parts[0], parts[1], parts[2], parts[3] === '1'))
      }
    }
    const compacted = KitchenStore.compactList(out)
    if (compacted.length !== out.length) {
      KitchenStore.saveList(compacted)
    }
    return compacted
  }

  static addListItem(title: string, quantity: string): boolean {
    const items = KitchenStore.listItems()
    const isNew = KitchenStore.upsertItem(items, title, quantity)
    KitchenStore.saveList(items)
    return isNew
  }

  static addIngredientLine(line: string): boolean {
    const parsed = KitchenStore.parseIngredient(line)
    return KitchenStore.addListItem(parsed.title, parsed.quantity)
  }

  static addRecipeIngredients(recipeId: string): number {
    const recipe = KitchenStore.findRecipe(recipeId)
    const items = KitchenStore.listItems()
    let added = 0
    for (const line of recipe.ingredients) {
      const parsed = KitchenStore.parseIngredient(line)
      if (KitchenStore.upsertItem(items, parsed.title, parsed.quantity)) {
        added += 1
      }
    }
    KitchenStore.saveList(items)
    return added
  }

  static toggleListItem(id: string): void {
    const items = KitchenStore.listItems()
    for (const item of items) {
      if (item.id === id) item.completed = !item.completed
    }
    KitchenStore.saveList(items)
  }

  static deleteListItem(id: string): void {
    const next: KitchenListItem[] = []
    for (const item of KitchenStore.listItems()) {
      if (item.id !== id) next.push(item)
    }
    KitchenStore.saveList(next)
  }

  static clearCompletedListItems(): void {
    const next: KitchenListItem[] = []
    for (const item of KitchenStore.listItems()) {
      if (!item.completed) next.push(item)
    }
    KitchenStore.saveList(next)
  }

  static stats(): KitchenStats {
    return new KitchenStats(
      KitchenStore.csvParts(AppStorage.get<string>(KEY_FAVORITES) ?? '').length,
      KitchenStore.csvParts(AppStorage.get<string>(KEY_COMPLETED) ?? '').length,
      KitchenStore.listItems().length,
    )
  }

  private static recipeContains(recipe: Recipe, query: string): boolean {
    if (recipe.title.indexOf(query) >= 0 || recipe.category.indexOf(query) >= 0 || recipe.meal.indexOf(query) >= 0 ||
      recipe.summary.indexOf(query) >= 0) {
      return true
    }
    for (const tag of recipe.tags) {
      if (tag.indexOf(query) >= 0) return true
    }
    for (const ingredient of recipe.ingredients) {
      if (ingredient.indexOf(query) >= 0) return true
    }
    return false
  }

  private static csvParts(raw: string): string[] {
    const out: string[] = []
    if (raw.length === 0) return out
    for (const p of raw.split(',')) {
      const v = p.trim()
      if (v.length > 0) out.push(v)
    }
    return out
  }

  private static hasInCsv(key: string, id: string): boolean {
    for (const p of KitchenStore.csvParts(AppStorage.get<string>(key) ?? '')) {
      if (p === id) return true
    }
    return false
  }

  private static toggleCsv(key: string, id: string): boolean {
    const parts = KitchenStore.csvParts(AppStorage.get<string>(key) ?? '')
    const next: string[] = []
    let existed = false
    for (const p of parts) {
      if (p === id) {
        existed = true
      } else {
        next.push(p)
      }
    }
    if (!existed) next.push(id)
    AppStorage.setOrCreate(key, next.join(','))
    return !existed
  }

  private static saveList(items: KitchenListItem[]): void {
    const rows: string[] = []
    for (const item of items) {
      rows.push(`${item.id}|${item.title}|${item.quantity}|${item.completed ? '1' : '0'}`)
    }
    AppStorage.setOrCreate(KEY_LIST, rows.join(';;'))
  }

  private static compactList(items: KitchenListItem[]): KitchenListItem[] {
    const out: KitchenListItem[] = []
    for (const item of items) {
      let merged = false
      if (!item.completed) {
        for (const exist of out) {
          if (!exist.completed && exist.title === item.title) {
            exist.quantity = KitchenStore.mergeQuantity(exist.quantity, item.quantity)
            merged = true
            break
          }
        }
      }
      if (!merged) {
        out.push(item)
      }
    }
    return out
  }

  private static upsertItem(items: KitchenListItem[], title: string, quantity: string): boolean {
    const t = title.trim()
    if (t.length === 0) {
      return false
    }
    const q = quantity.trim().length > 0 ? quantity.trim() : '1'
    for (const item of items) {
      if (!item.completed && item.title === t) {
        item.quantity = KitchenStore.mergeQuantity(item.quantity, q)
        return false
      }
    }
    items.push(new KitchenListItem(`k${items.length}-${Date.now()}`, t, q, false))
    return true
  }

  private static mergeQuantity(current: string, incoming: string): string {
    const a = KitchenStore.leadingNumber(current)
    const b = KitchenStore.leadingNumber(incoming)
    const unit = KitchenStore.trailingUnit(current).length > 0
      ? KitchenStore.trailingUnit(current)
      : KitchenStore.trailingUnit(incoming)
    if (a > 0 && b > 0) {
      if (unit.length > 0) {
        return `${a + b} ${unit}`
      }
      return `${a + b}`
    }
    if (incoming.length > 0 && incoming !== '1') {
      return incoming
    }
    return current
  }

  private static leadingNumber(raw: string): number {
    let i = 0
    let n = 0
    let found = false
    while (i < raw.length) {
      const code = raw.charCodeAt(i)
      if (code >= 48 && code <= 57) {
        found = true
        n = n * 10 + (code - 48)
        i += 1
      } else if (!found && (raw.charAt(i) === ' ' || raw.charAt(i) === '×')) {
        i += 1
      } else {
        break
      }
    }
    if (!found) {
      return 0
    }
    return n
  }

  private static trailingUnit(raw: string): string {
    let i = 0
    while (i < raw.length) {
      const ch = raw.charAt(i)
      const code = raw.charCodeAt(i)
      if ((code >= 48 && code <= 57) || ch === ' ' || ch === '×') {
        i += 1
      } else {
        break
      }
    }
    return raw.substring(i).trim()
  }

  private static parseIngredient(line: string): KitchenListItem {
    const parts = line.split('×')
    if (parts.length >= 2) {
      return new KitchenListItem('', parts[0].trim(), parts[1].trim(), false)
    }
    return new KitchenListItem('', line.trim(), '1', false)
  }
}
