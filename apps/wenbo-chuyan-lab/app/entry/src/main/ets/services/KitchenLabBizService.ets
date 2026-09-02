import { HttpClient } from './HttpClient'
import { AuthService } from './AuthService'
import {
  CategoryItem,
  CategoryListWire,
  DeleteOkWire,
  ExperimentNote,
  IngredientLine,
  KpiItem,
  KpiListWire,
  MessageItem,
  MessageListWire,
  NoteListWire,
  NoteWire,
  NoteWriteBody,
  PantryItem,
  PantryListWire,
  PantryWire,
  PantryWriteBody,
  RecipeItem,
  RecipeListWire,
  RecipeWire,
  ShoppingItem,
  ShoppingListWire,
  ShoppingWire,
  ShoppingWriteBody
} from '../models/KitchenLabModels'

/**
 * 栏目与写操作走平台 /biz/kitchen-lab/*；失败返回空列表，禁止 localSeed。
 */
export class KitchenLabBizService {
  private static uid(): string {
    return AuthService.currentUsername()
  }

  static async loadRecipes(cuisine: string = '', difficulty: string = ''): Promise<RecipeItem[]> {
    let path = '/biz/kitchen-lab/recipes'
    const params: string[] = []
    if (cuisine.length > 0) {
      params.push(`cuisine=${encodeURIComponent(cuisine)}`)
    }
    if (difficulty.length > 0) {
      params.push(`difficulty=${encodeURIComponent(difficulty)}`)
    }
    if (params.length > 0) {
      path = `${path}?${params.join('&')}`
    }
    const res = await HttpClient.get<RecipeListWire>(path)
    if (res.code === 0 && res.data !== undefined) {
      return KitchenLabBizService.mapRecipes(res.data.list)
    }
    return []
  }

  static async loadRecipeById(id: string): Promise<RecipeItem | undefined> {
    const res = await HttpClient.get<RecipeWire>(`/biz/kitchen-lab/recipes/${id}`)
    if (res.code === 0 && res.data !== undefined) {
      return KitchenLabBizService.mapRecipe(res.data)
    }
    const list = await KitchenLabBizService.loadRecipes()
    return KitchenLabBizService.findRecipe(list, id)
  }

  static async matchRecipes(ingredientNames: string[]): Promise<RecipeItem[]> {
    if (ingredientNames.length === 0) {
      return []
    }
    const q = ingredientNames.join(',')
    const res = await HttpClient.get<RecipeListWire>(
      `/biz/kitchen-lab/recipes/match?ingredients=${encodeURIComponent(q)}`
    )
    if (res.code === 0 && res.data !== undefined) {
      return KitchenLabBizService.mapRecipes(res.data.list)
    }
    return []
  }

  static async loadCategories(): Promise<CategoryItem[]> {
    const res = await HttpClient.get<CategoryListWire>('/biz/kitchen-lab/categories')
    if (res.code === 0 && res.data !== undefined) {
      return res.data.list
    }
    return []
  }

  static async loadKpis(): Promise<KpiItem[]> {
    const res = await HttpClient.get<KpiListWire>('/biz/kitchen-lab/kpis')
    if (res.code === 0 && res.data !== undefined) {
      return res.data.list
    }
    return []
  }

  static async loadMessages(): Promise<MessageItem[]> {
    const res = await HttpClient.get<MessageListWire>('/biz/kitchen-lab/messages')
    if (res.code === 0 && res.data !== undefined) {
      return res.data.list
    }
    return []
  }

  static async loadPantry(category: string = ''): Promise<PantryItem[]> {
    const uid = KitchenLabBizService.uid()
    if (uid.length === 0 || uid === '未登录') {
      return []
    }
    let path = `/biz/kitchen-lab/pantry?userId=${encodeURIComponent(uid)}`
    if (category.length > 0) {
      path = `${path}&category=${encodeURIComponent(category)}`
    }
    const res = await HttpClient.get<PantryListWire>(path)
    if (res.code === 0 && res.data !== undefined) {
      return KitchenLabBizService.mapPantry(res.data.list)
    }
    return []
  }

  static async createPantry(body: PantryWriteBody): Promise<PantryItem | undefined> {
    body.userId = KitchenLabBizService.uid()
    const res = await HttpClient.post<PantryWire>('/biz/kitchen-lab/pantry', body)
    if (res.code === 0 && res.data !== undefined) {
      return KitchenLabBizService.mapPantryItem(res.data)
    }
    return undefined
  }

  static async updatePantry(id: string, body: PantryWriteBody): Promise<PantryItem | undefined> {
    body.userId = KitchenLabBizService.uid()
    const res = await HttpClient.put<PantryWire>(`/biz/kitchen-lab/pantry/${id}`, body)
    if (res.code === 0 && res.data !== undefined) {
      return KitchenLabBizService.mapPantryItem(res.data)
    }
    return undefined
  }

  static async deletePantry(id: string): Promise<boolean> {
    const uid = KitchenLabBizService.uid()
    const res = await HttpClient.delete<DeleteOkWire>(
      `/biz/kitchen-lab/pantry/${id}?userId=${encodeURIComponent(uid)}`
    )
    return res.code === 0
  }

  static async loadShopping(): Promise<ShoppingItem[]> {
    const uid = KitchenLabBizService.uid()
    if (uid.length === 0 || uid === '未登录') {
      return []
    }
    const res = await HttpClient.get<ShoppingListWire>(
      `/biz/kitchen-lab/shopping?userId=${encodeURIComponent(uid)}`
    )
    if (res.code === 0 && res.data !== undefined) {
      return KitchenLabBizService.mapShopping(res.data.list)
    }
    return []
  }

  static async createShopping(body: ShoppingWriteBody): Promise<ShoppingItem | undefined> {
    body.userId = KitchenLabBizService.uid()
    const res = await HttpClient.post<ShoppingWire>('/biz/kitchen-lab/shopping', body)
    if (res.code === 0 && res.data !== undefined) {
      return KitchenLabBizService.mapShoppingItem(res.data)
    }
    return undefined
  }

  static async updateShopping(id: string, body: ShoppingWriteBody): Promise<ShoppingItem | undefined> {
    body.userId = KitchenLabBizService.uid()
    const res = await HttpClient.put<ShoppingWire>(`/biz/kitchen-lab/shopping/${id}`, body)
    if (res.code === 0 && res.data !== undefined) {
      return KitchenLabBizService.mapShoppingItem(res.data)
    }
    return undefined
  }

  static async deleteShopping(id: string): Promise<boolean> {
    const uid = KitchenLabBizService.uid()
    const res = await HttpClient.delete<DeleteOkWire>(
      `/biz/kitchen-lab/shopping/${id}?userId=${encodeURIComponent(uid)}`
    )
    return res.code === 0
  }

  static async loadNotes(): Promise<ExperimentNote[]> {
    const uid = KitchenLabBizService.uid()
    if (uid.length === 0 || uid === '未登录') {
      return []
    }
    const res = await HttpClient.get<NoteListWire>(
      `/biz/kitchen-lab/notes?userId=${encodeURIComponent(uid)}`
    )
    if (res.code === 0 && res.data !== undefined) {
      return KitchenLabBizService.mapNotes(res.data.list)
    }
    return []
  }

  static async createNote(body: NoteWriteBody): Promise<ExperimentNote | undefined> {
    body.userId = KitchenLabBizService.uid()
    const res = await HttpClient.post<NoteWire>('/biz/kitchen-lab/notes', body)
    if (res.code === 0 && res.data !== undefined) {
      return KitchenLabBizService.mapNote(res.data)
    }
    return undefined
  }

  static async deleteNote(id: string): Promise<boolean> {
    const uid = KitchenLabBizService.uid()
    const res = await HttpClient.delete<DeleteOkWire>(
      `/biz/kitchen-lab/notes/${id}?userId=${encodeURIComponent(uid)}`
    )
    return res.code === 0
  }

  static findRecipe(list: RecipeItem[], id: string): RecipeItem | undefined {
    for (let r of list) {
      if (r.id === id) {
        return r
      }
    }
    return undefined
  }

  private static mapRecipes(wires: RecipeWire[]): RecipeItem[] {
    const out: RecipeItem[] = []
    for (let w of wires) {
      out.push(KitchenLabBizService.mapRecipe(w))
    }
    return out
  }

  private static mapRecipe(w: RecipeWire): RecipeItem {
    const r = new RecipeItem()
    r.id = w.id ?? ''
    r.title = w.title ?? ''
    r.summary = w.summary ?? ''
    r.body = w.body ?? w.description ?? ''
    r.description = w.description ?? w.body ?? ''
    r.coverKey = w.coverKey ?? w.coverMedia ?? ''
    r.cuisine = w.cuisine ?? ''
    r.difficulty = w.difficulty ?? ''
    r.cookingTime = w.cookingTime ?? ''
    r.servings = w.servings ?? ''
    r.matchScore = w.matchScore ?? 0
    r.matchRatio = w.matchRatio ?? 0
    r.ingredients = KitchenLabBizService.parseIngredients(w.ingredientsJson)
    r.steps = KitchenLabBizService.parseSteps(w.stepsJson)
    return r
  }

  private static parseIngredients(raw: string): IngredientLine[] {
    const out: IngredientLine[] = []
    try {
      const parsed = JSON.parse(raw) as IngredientLine[]
      for (let row of parsed) {
        const line = new IngredientLine()
        line.name = row.name ?? ''
        line.amount = row.amount ?? ''
        if (line.name.length > 0) {
          out.push(line)
        }
      }
    } catch {
      // empty
    }
    return out
  }

  private static parseSteps(raw: string): string[] {
    try {
      const parsed = JSON.parse(raw) as string[]
      const out: string[] = []
      for (let s of parsed) {
        if (typeof s === 'string' && s.length > 0) {
          out.push(s)
        }
      }
      return out
    } catch {
      return []
    }
  }

  private static mapPantry(wires: PantryWire[]): PantryItem[] {
    const out: PantryItem[] = []
    for (let w of wires) {
      out.push(KitchenLabBizService.mapPantryItem(w))
    }
    return out
  }

  private static mapPantryItem(w: PantryWire): PantryItem {
    const p = new PantryItem()
    p.id = w.id ?? ''
    p.title = w.title ?? ''
    p.category = w.category ?? ''
    p.quantity = w.quantity ?? ''
    p.unit = w.unit ?? ''
    p.purchaseDate = w.purchaseDate ?? ''
    p.expiryDate = w.expiryDate ?? ''
    p.remark = w.remark ?? ''
    p.userId = w.userId ?? ''
    p.status = w.status ?? 'active'
    return p
  }

  private static mapShopping(wires: ShoppingWire[]): ShoppingItem[] {
    const out: ShoppingItem[] = []
    for (let w of wires) {
      out.push(KitchenLabBizService.mapShoppingItem(w))
    }
    return out
  }

  private static mapShoppingItem(w: ShoppingWire): ShoppingItem {
    const s = new ShoppingItem()
    s.id = w.id ?? ''
    s.title = w.title ?? ''
    s.qty = w.qty ?? ''
    s.unit = w.unit ?? ''
    s.isChecked = w.isChecked === true
    s.remark = w.remark ?? ''
    s.userId = w.userId ?? ''
    s.status = w.status ?? 'pending'
    return s
  }

  private static mapNotes(wires: NoteWire[]): ExperimentNote[] {
    const out: ExperimentNote[] = []
    for (let w of wires) {
      out.push(KitchenLabBizService.mapNote(w))
    }
    return out
  }

  private static mapNote(w: NoteWire): ExperimentNote {
    const n = new ExperimentNote()
    n.id = w.id ?? ''
    n.title = w.title ?? ''
    n.summary = w.summary ?? ''
    n.body = w.body ?? ''
    n.recipeId = w.recipeId ?? ''
    n.rating = w.rating ?? 0
    n.modifications = w.modifications ?? ''
    n.userId = w.userId ?? ''
    n.status = w.status ?? 'active'
    n.updatedAt = w.updatedAt ?? ''
    return n
  }
}
