export class RecipeStep {
  key: string = ''
  numberText: string = ''
  text: string = ''

  constructor(key: string, numberText: string, text: string) {
    this.key = key
    this.numberText = numberText
    this.text = text
  }
}

export class Recipe {
  id: string = ''
  title: string = ''
  category: string = ''
  meal: string = ''
  coverKey: string = ''
  summary: string = ''
  timeText: string = ''
  difficulty: string = ''
  servings: string = ''
  ingredients: string[] = []
  steps: string[] = []
  tags: string[] = []

  constructor(
    id: string,
    title: string,
    category: string,
    meal: string,
    coverKey: string,
    summary: string,
    timeText: string,
    difficulty: string,
    servings: string,
    ingredients: string[],
    steps: string[],
    tags: string[],
  ) {
    this.id = id
    this.title = title
    this.category = category
    this.meal = meal
    this.coverKey = coverKey
    this.summary = summary
    this.timeText = timeText
    this.difficulty = difficulty
    this.servings = servings
    this.ingredients = ingredients
    this.steps = steps
    this.tags = tags
  }

  stepItems(): RecipeStep[] {
    const items: RecipeStep[] = []
    let n = 1
    for (const text of this.steps) {
      items.push(new RecipeStep(`${this.id}-${n}`, `${n}`, text))
      n += 1
    }
    return items
  }
}

export class RecipeMatch {
  recipe: Recipe = new Recipe('', '', '', '', '', '', '', '', '', [], [], [])
  matchedIngredients: string[] = []
  reason: string = ''

  constructor(recipe: Recipe, matchedIngredients: string[], reason: string) {
    this.recipe = recipe
    this.matchedIngredients = matchedIngredients
    this.reason = reason
  }
}

export class KitchenListItem {
  id: string = ''
  title: string = ''
  quantity: string = ''
  completed: boolean = false

  constructor(id: string, title: string, quantity: string, completed: boolean) {
    this.id = id
    this.title = title
    this.quantity = quantity
    this.completed = completed
  }
}

export class KitchenStats {
  favoriteCount: number = 0
  completedCount: number = 0
  listCount: number = 0

  constructor(favoriteCount: number, completedCount: number, listCount: number) {
    this.favoriteCount = favoriteCount
    this.completedCount = completedCount
    this.listCount = listCount
  }
}
