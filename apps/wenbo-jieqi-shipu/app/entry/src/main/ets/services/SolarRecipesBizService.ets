import { HttpClient } from './HttpClient'
import { AuthService } from './AuthService'
import { SolarTermUtil } from './SolarTermUtil'
import {
  FavoriteCreateRequest,
  FavoriteItem,
  FavoriteListPayload,
  FavoriteWire,
  RecipeItem,
  RecipeFilter,
  RecipeListPayload,
  RecipeWire,
  TermItem,
  TermListPayload,
  TermWire,
  TipItem,
  TipListPayload,
  TipWire
} from '../models/SolarModels'

export class SolarRecipesBizService {
  static async loadTerms(): Promise<TermItem[]> {
    const res = await HttpClient.get<TermListPayload>('/biz/solar-recipes/terms')
    if (res.code === 0 && res.data !== undefined && res.data.list !== undefined) {
      const out: TermItem[] = []
      for (const w of res.data.list) {
        out.push(TermItem.fromWire(w))
      }
      return out
    }
    return []
  }

  static async findTerm(id: string): Promise<TermItem | undefined> {
    const res = await HttpClient.get<TermWire>(`/biz/solar-recipes/terms/${id}`)
    if (res.code === 0 && res.data !== undefined) {
      return TermItem.fromWire(res.data)
    }
    const all = await SolarRecipesBizService.loadTerms()
    for (const t of all) {
      if (t.id === id) {
        return t
      }
    }
    return undefined
  }

  static async loadRecipes(filter?: RecipeFilter): Promise<RecipeItem[]> {
    let path = '/biz/solar-recipes/recipes?'
    const parts: string[] = []
    if (filter !== undefined) {
      if (filter.solarTerm.length > 0) {
        parts.push(`solarTerm=${encodeURIComponent(filter.solarTerm)}`)
      }
      if (filter.solarTermId.length > 0) {
        parts.push(`solarTermId=${encodeURIComponent(filter.solarTermId)}`)
      }
      if (filter.ingredientType.length > 0) {
        parts.push(`ingredientType=${encodeURIComponent(filter.ingredientType)}`)
      }
      if (filter.effect.length > 0) {
        parts.push(`effect=${encodeURIComponent(filter.effect)}`)
      }
      if (filter.q.length > 0) {
        parts.push(`q=${encodeURIComponent(filter.q)}`)
      }
    }
    path += parts.join('&')
    const res = await HttpClient.get<RecipeListPayload>(path)
    if (res.code === 0 && res.data !== undefined && res.data.list !== undefined) {
      const out: RecipeItem[] = []
      for (const w of res.data.list) {
        out.push(RecipeItem.fromWire(w))
      }
      return out
    }
    return []
  }

  static async findRecipe(id: string): Promise<RecipeItem | undefined> {
    const res = await HttpClient.get<RecipeWire>(`/biz/solar-recipes/recipes/${id}`)
    if (res.code === 0 && res.data !== undefined) {
      return RecipeItem.fromWire(res.data)
    }
    const all = await SolarRecipesBizService.loadRecipes()
    for (const r of all) {
      if (r.id === id) {
        return r
      }
    }
    return undefined
  }

  static async loadTips(solarTermId: string = ''): Promise<TipItem[]> {
    let path = '/biz/solar-recipes/tips'
    if (solarTermId.length > 0) {
      path += `?solarTermId=${encodeURIComponent(solarTermId)}`
    }
    const res = await HttpClient.get<TipListPayload>(path)
    if (res.code === 0 && res.data !== undefined && res.data.list !== undefined) {
      const out: TipItem[] = []
      for (const w of res.data.list) {
        out.push(TipItem.fromWire(w))
      }
      return out
    }
    return []
  }

  static async loadFavorites(): Promise<FavoriteItem[]> {
    if (!AuthService.isLoggedIn()) {
      return []
    }
    const uid = AuthService.currentUsername()
    const res = await HttpClient.get<FavoriteListPayload>(`/biz/solar-recipes/favorites?userId=${uid}`)
    if (res.code === 0 && res.data !== undefined && res.data.list !== undefined) {
      const out: FavoriteItem[] = []
      for (const w of res.data.list) {
        out.push(FavoriteItem.fromWire(w))
      }
      return out
    }
    return []
  }

  static async toggleFavorite(recipe: RecipeItem): Promise<boolean> {
    const list = await SolarRecipesBizService.loadFavorites()
    for (const f of list) {
      if (f.targetId === recipe.id) {
        const uid = AuthService.currentUsername()
        const res = await HttpClient.delete<FavoriteWire>(`/biz/solar-recipes/favorites/${f.id}?userId=${uid}`)
        return res.code === 0 ? false : true
      }
    }
    const req = new FavoriteCreateRequest()
    req.kind = 'recipe'
    req.targetId = recipe.id
    req.title = recipe.title
    req.coverKey = recipe.coverKey
    req.userId = AuthService.currentUsername()
    const res = await HttpClient.post<FavoriteWire>('/biz/solar-recipes/favorites', req)
    return res.code === 0
  }

  static async isFavored(targetId: string): Promise<boolean> {
    const list = await SolarRecipesBizService.loadFavorites()
    for (const f of list) {
      if (f.targetId === targetId) {
        return true
      }
    }
    return false
  }

  static async todayRecommendations(limit: number = 3): Promise<RecipeItem[]> {
    const termId = SolarTermUtil.currentTermId()
    const termName = SolarTermUtil.currentTermName()
    const byTermId = new RecipeFilter()
    byTermId.solarTermId = termId
    let list = await SolarRecipesBizService.loadRecipes(byTermId)
    if (list.length === 0) {
      const byTermName = new RecipeFilter()
      byTermName.solarTerm = termName
      list = await SolarRecipesBizService.loadRecipes(byTermName)
    }
    if (list.length === 0) {
      list = await SolarRecipesBizService.loadRecipes()
    }
    const featured: RecipeItem[] = []
    const rest: RecipeItem[] = []
    for (const r of list) {
      if (r.featured) {
        featured.push(r)
      } else {
        rest.push(r)
      }
    }
    const merged: RecipeItem[] = []
    for (const f of featured) {
      merged.push(f)
    }
    for (const r of rest) {
      merged.push(r)
    }
    const out: RecipeItem[] = []
    for (let i = 0; i < merged.length && out.length < limit; i++) {
      out.push(merged[i])
    }
    return out
  }

  static ingredientTypes(): string[] {
    return ['谷物', '蔬菜', '肉类', '水产', '水果']
  }

  static effects(): string[] {
    return ['润燥', '祛湿', '温补', '清热']
  }
}
