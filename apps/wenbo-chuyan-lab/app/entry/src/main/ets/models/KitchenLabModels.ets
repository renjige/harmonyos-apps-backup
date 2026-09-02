export class IngredientLine {
  name: string = ''
  amount: string = ''
}

export class RecipeItem {
  id: string = ''
  title: string = ''
  summary: string = ''
  body: string = ''
  description: string = ''
  coverKey: string = ''
  cuisine: string = ''
  difficulty: string = ''
  cookingTime: string = ''
  servings: string = ''
  ingredients: IngredientLine[] = []
  steps: string[] = []
  matchScore: number = 0
  matchRatio: number = 0
}

export class PantryItem {
  id: string = ''
  title: string = ''
  category: string = ''
  quantity: string = ''
  unit: string = ''
  purchaseDate: string = ''
  expiryDate: string = ''
  remark: string = ''
  userId: string = ''
  status: string = 'active'
}

export class ShoppingItem {
  id: string = ''
  title: string = ''
  qty: string = ''
  unit: string = ''
  isChecked: boolean = false
  remark: string = ''
  userId: string = ''
  status: string = 'pending'
}

export class ExperimentNote {
  id: string = ''
  title: string = ''
  summary: string = ''
  body: string = ''
  recipeId: string = ''
  rating: number = 0
  modifications: string = ''
  userId: string = ''
  status: string = 'active'
  updatedAt: string = ''
}

export class KpiItem {
  key: string = ''
  label: string = ''
  value: number = 0
}

export class MessageItem {
  id: string = ''
  title: string = ''
  body: string = ''
  type: string = ''
  read: boolean = false
  createdAt: string = ''
}

export class CategoryItem {
  id: string = ''
  title: string = ''
}

export class RecipeWire {
  id: string = ''
  title: string = ''
  summary: string = ''
  body: string = ''
  description: string = ''
  coverKey: string = ''
  coverMedia: string = ''
  cuisine: string = ''
  difficulty: string = ''
  cookingTime: string = ''
  servings: string = ''
  ingredientsJson: string = ''
  stepsJson: string = ''
  matchScore: number = 0
  matchRatio: number = 0
}

export class RecipeListWire {
  list: RecipeWire[] = []
}

export class PantryWire {
  id: string = ''
  title: string = ''
  category: string = ''
  quantity: string = ''
  unit: string = ''
  purchaseDate: string = ''
  expiryDate: string = ''
  remark: string = ''
  userId: string = ''
  status: string = ''
}

export class PantryListWire {
  list: PantryWire[] = []
}

export class ShoppingWire {
  id: string = ''
  title: string = ''
  qty: string = ''
  unit: string = ''
  isChecked: boolean = false
  remark: string = ''
  userId: string = ''
  status: string = ''
}

export class ShoppingListWire {
  list: ShoppingWire[] = []
}

export class NoteWire {
  id: string = ''
  title: string = ''
  summary: string = ''
  body: string = ''
  recipeId: string = ''
  rating: number = 0
  modifications: string = ''
  userId: string = ''
  status: string = ''
  updatedAt: string = ''
}

export class NoteListWire {
  list: NoteWire[] = []
}

export class KpiListWire {
  list: KpiItem[] = []
}

export class MessageListWire {
  list: MessageItem[] = []
}

export class CategoryListWire {
  list: CategoryItem[] = []
}

export class PantryWriteBody {
  title: string = ''
  category: string = ''
  quantity: string = ''
  unit: string = ''
  purchaseDate: string = ''
  expiryDate: string = ''
  remark: string = ''
  userId: string = ''
  status: string = 'active'

  toJsonString(): string {
    return JSON.stringify({
      title: this.title,
      category: this.category,
      quantity: this.quantity,
      unit: this.unit,
      purchaseDate: this.purchaseDate,
      expiryDate: this.expiryDate,
      remark: this.remark,
      userId: this.userId,
      status: this.status
    })
  }
}

export class ShoppingWriteBody {
  title: string = ''
  qty: string = ''
  unit: string = ''
  isChecked: boolean = false
  remark: string = ''
  userId: string = ''
  status: string = 'pending'

  toJsonString(): string {
    return JSON.stringify({
      title: this.title,
      qty: this.qty,
      unit: this.unit,
      isChecked: this.isChecked,
      remark: this.remark,
      userId: this.userId,
      status: this.status
    })
  }
}

export class NoteWriteBody {
  title: string = ''
  summary: string = ''
  body: string = ''
  recipeId: string = ''
  rating: number = 0
  modifications: string = ''
  userId: string = ''
  status: string = 'active'

  toJsonString(): string {
    return JSON.stringify({
      title: this.title,
      summary: this.summary,
      body: this.body,
      recipeId: this.recipeId,
      rating: this.rating,
      modifications: this.modifications,
      userId: this.userId,
      status: this.status
    })
  }
}

export class DeleteOkWire {
  success: boolean = false
}
