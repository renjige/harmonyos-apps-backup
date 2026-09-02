/** 节气食谱 — 平台 Wire 与本地模型 */

export class RecipeWire {
  id: string = ''
  title: string = ''
  subtitle: string = ''
  summary: string = ''
  body: string = ''
  description: string = ''
  coverKey: string = ''
  coverMedia: string = ''
  solarTerm: string = ''
  solarTermId: string = ''
  category: string = ''
  ingredientType: string = ''
  effect: string = ''
  ingredients: string[] = []
  steps: string[] = []
  healthBenefits: string = ''
  suitableFor: string = ''
  cookingTime: number = 0
  difficulty: string = ''
  isVegetarian: boolean = false
  featured: boolean = false
}

export class RecipeItem {
  id: string = ''
  title: string = ''
  summary: string = ''
  body: string = ''
  coverKey: string = ''
  solarTerm: string = ''
  solarTermId: string = ''
  category: string = ''
  ingredientType: string = ''
  effect: string = ''
  ingredients: string[] = []
  steps: string[] = []
  healthBenefits: string = ''
  suitableFor: string = ''
  cookingTime: number = 0
  difficulty: string = ''
  isVegetarian: boolean = false
  featured: boolean = false

  metaLine(): string {
    return `${this.solarTerm} · ${this.cookingTime}分钟 · ${this.difficulty}`
  }

  static fromWire(w: RecipeWire): RecipeItem {
    const item = new RecipeItem()
    item.id = w.id
    item.title = w.title
    item.summary = w.summary ?? ''
    item.body = w.body !== undefined && w.body.length > 0 ? w.body : (w.description ?? '')
    item.coverKey = SolarModels.resolveCover(w.coverKey, w.coverMedia)
    item.solarTerm = w.solarTerm ?? ''
    item.solarTermId = w.solarTermId ?? ''
    item.category = w.category ?? ''
    item.ingredientType = w.ingredientType ?? ''
    item.effect = w.effect ?? ''
    item.ingredients = w.ingredients ?? []
    item.steps = w.steps ?? []
    item.healthBenefits = w.healthBenefits ?? ''
    item.suitableFor = w.suitableFor ?? ''
    item.cookingTime = w.cookingTime ?? 0
    item.difficulty = w.difficulty ?? '简单'
    item.isVegetarian = w.isVegetarian === true
    item.featured = w.featured === true
    return item
  }
}

export class TermWire {
  id: string = ''
  title: string = ''
  subtitle: string = ''
  summary: string = ''
  body: string = ''
  description: string = ''
  coverKey: string = ''
  coverMedia: string = ''
  dateRange: string = ''
  poem: string = ''
  seasonalFoods: string[] = []
}

export class TermItem {
  id: string = ''
  title: string = ''
  summary: string = ''
  body: string = ''
  coverKey: string = ''
  dateRange: string = ''
  poem: string = ''
  seasonalFoods: string[] = []

  static fromWire(w: TermWire): TermItem {
    const item = new TermItem()
    item.id = w.id
    item.title = w.title
    item.summary = w.summary ?? ''
    item.body = w.body !== undefined && w.body.length > 0 ? w.body : (w.description ?? '')
    item.coverKey = SolarModels.resolveCover(w.coverKey, w.coverMedia)
    item.dateRange = w.dateRange ?? (w.subtitle ?? '')
    item.poem = w.poem ?? ''
    item.seasonalFoods = w.seasonalFoods ?? []
    return item
  }
}

export class TipWire {
  id: string = ''
  title: string = ''
  summary: string = ''
  body: string = ''
  description: string = ''
  coverKey: string = ''
  coverMedia: string = ''
  solarTerm: string = ''
  solarTermId: string = ''
}

export class TipItem {
  id: string = ''
  title: string = ''
  summary: string = ''
  body: string = ''
  coverKey: string = ''
  solarTerm: string = ''
  solarTermId: string = ''

  static fromWire(w: TipWire): TipItem {
    const item = new TipItem()
    item.id = w.id
    item.title = w.title
    item.summary = w.summary ?? ''
    item.body = w.body !== undefined && w.body.length > 0 ? w.body : (w.description ?? '')
    item.coverKey = SolarModels.resolveCover(w.coverKey, w.coverMedia)
    item.solarTerm = w.solarTerm ?? ''
    item.solarTermId = w.solarTermId ?? ''
    return item
  }
}

export class FavoriteWire {
  id: string = ''
  title: string = ''
  kind: string = ''
  targetId: string = ''
  coverKey: string = ''
}

export class FavoriteItem {
  id: string = ''
  title: string = ''
  kind: string = ''
  targetId: string = ''
  coverKey: string = ''

  static fromWire(w: FavoriteWire): FavoriteItem {
    const item = new FavoriteItem()
    item.id = w.id
    item.title = w.title
    item.kind = w.kind ?? 'recipe'
    item.targetId = w.targetId ?? ''
    item.coverKey = w.coverKey ?? ''
    return item
  }
}

export class RecipeListPayload {
  list: RecipeWire[] = []
}

export class TermListPayload {
  list: TermWire[] = []
}

export class TipListPayload {
  list: TipWire[] = []
}

export class FavoriteListPayload {
  list: FavoriteWire[] = []
}

export class FavoriteCreateRequest {
  kind: string = 'recipe'
  targetId: string = ''
  title: string = ''
  coverKey: string = ''
  userId: string = ''

  toJsonString(): string {
    return `{"kind":${JSON.stringify(this.kind)},"targetId":${JSON.stringify(this.targetId)},"title":${JSON.stringify(this.title)},"coverKey":${JSON.stringify(this.coverKey)},"userId":${JSON.stringify(this.userId)}}`
  }
}

export class RecipeFilter {
  solarTerm: string = ''
  solarTermId: string = ''
  ingredientType: string = ''
  effect: string = ''
  q: string = ''
}

export class SolarModels {
  static resolveCover(coverKey: string | undefined, coverMedia: string | undefined): string {
    if (coverKey !== undefined && coverKey.length > 0) {
      return coverKey
    }
    if (coverMedia !== undefined && coverMedia.length > 0) {
      return coverMedia
    }
    return 'hero_bg'
  }
}
