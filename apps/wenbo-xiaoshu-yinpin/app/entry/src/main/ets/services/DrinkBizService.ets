import { HttpClient } from './HttpClient'
import { AuthService } from './AuthService'
import {
  DrinkItem,
  DrinkListPayload,
  DrinkWire,
  FavoriteCreateRequest,
  FavoriteItem,
  FavoriteListPayload,
  FavoriteWire,
  MessageItem,
  MessageListPayload,
  TipItem,
  TipListPayload,
  TipWire,
  TryCreateRequest,
  TryItem,
  TryListPayload,
  TryWire
} from '../models/DrinkModels'

export class DrinkBizService {
  static async loadDrinks(): Promise<DrinkItem[]> {
    const res = await HttpClient.get<DrinkListPayload>('/biz/summer-drinks/drinks')
    if (res.code === 0 && res.data !== undefined && res.data.list !== undefined) {
      const out: DrinkItem[] = []
      for (const w of res.data.list) {
        out.push(DrinkItem.fromWire(w))
      }
      return out
    }
    return []
  }

  static async findDrink(id: string): Promise<DrinkItem | undefined> {
    const res = await HttpClient.get<DrinkWire>(`/biz/summer-drinks/drinks/${id}`)
    if (res.code === 0 && res.data !== undefined) {
      return DrinkItem.fromWire(res.data)
    }
    const all = await DrinkBizService.loadDrinks()
    for (const d of all) {
      if (d.id === id) {
        return d
      }
    }
    return undefined
  }

  static async loadTips(): Promise<TipItem[]> {
    const res = await HttpClient.get<TipListPayload>('/biz/summer-drinks/tips')
    if (res.code === 0 && res.data !== undefined && res.data.list !== undefined) {
      const out: TipItem[] = []
      for (const w of res.data.list) {
        out.push(TipItem.fromWire(w))
      }
      return out
    }
    return []
  }

  static async findTip(id: string): Promise<TipItem | undefined> {
    const res = await HttpClient.get<TipWire>(`/biz/summer-drinks/tips/${id}`)
    if (res.code === 0 && res.data !== undefined) {
      return TipItem.fromWire(res.data)
    }
    const all = await DrinkBizService.loadTips()
    for (const t of all) {
      if (t.id === id) {
        return t
      }
    }
    return undefined
  }

  static async loadTries(): Promise<TryItem[]> {
    if (!AuthService.isLoggedIn()) {
      return []
    }
    const uid = AuthService.currentUsername()
    const res = await HttpClient.get<TryListPayload>(`/biz/summer-drinks/tries?userId=${uid}`)
    if (res.code === 0 && res.data !== undefined && res.data.list !== undefined) {
      const out: TryItem[] = []
      for (const w of res.data.list) {
        out.push(TryItem.fromWire(w))
      }
      return out
    }
    return []
  }

  static async createTry(drink: DrinkItem, note: string): Promise<boolean> {
    const req = new TryCreateRequest()
    req.title = drink.title
    req.drinkId = drink.id
    req.drinkName = drink.title
    req.coverKey = drink.coverKey
    req.note = note
    const now = new Date()
    const m = now.getMonth() + 1
    const d = now.getDate()
    const mm = m < 10 ? `0${m}` : `${m}`
    const dd = d < 10 ? `0${d}` : `${d}`
    req.tryDate = `${now.getFullYear()}-${mm}-${dd}`
    req.userId = AuthService.currentUsername()
    const res = await HttpClient.post<TryWire>('/biz/summer-drinks/tries', req)
    return res.code === 0
  }

  static async deleteTry(id: string): Promise<boolean> {
    const uid = AuthService.currentUsername()
    const res = await HttpClient.delete<TryWire>(`/biz/summer-drinks/tries/${id}?userId=${uid}`)
    return res.code === 0
  }

  static async loadFavorites(): Promise<FavoriteItem[]> {
    if (!AuthService.isLoggedIn()) {
      return []
    }
    const uid = AuthService.currentUsername()
    const res = await HttpClient.get<FavoriteListPayload>(`/biz/summer-drinks/favorites?userId=${uid}`)
    if (res.code === 0 && res.data !== undefined && res.data.list !== undefined) {
      const out: FavoriteItem[] = []
      for (const w of res.data.list) {
        out.push(FavoriteItem.fromWire(w))
      }
      return out
    }
    return []
  }

  static async toggleFavorite(drink: DrinkItem): Promise<boolean> {
    const list = await DrinkBizService.loadFavorites()
    for (const f of list) {
      if (f.targetId === drink.id) {
        const uid = AuthService.currentUsername()
        const res = await HttpClient.delete<FavoriteWire>(`/biz/summer-drinks/favorites/${f.id}?userId=${uid}`)
        return res.code === 0 ? false : true
      }
    }
    const req = new FavoriteCreateRequest()
    req.kind = 'drink'
    req.targetId = drink.id
    req.title = drink.title
    req.coverKey = drink.coverKey
    req.userId = AuthService.currentUsername()
    const res = await HttpClient.post<FavoriteWire>('/biz/summer-drinks/favorites', req)
    return res.code === 0
  }

  static async isFavored(targetId: string): Promise<boolean> {
    const list = await DrinkBizService.loadFavorites()
    for (const f of list) {
      if (f.targetId === targetId) {
        return true
      }
    }
    return false
  }

  static async loadMessages(): Promise<MessageItem[]> {
    const res = await HttpClient.get<MessageListPayload>('/messages')
    if (res.code === 0 && res.data !== undefined && res.data.list !== undefined) {
      const out: MessageItem[] = []
      for (const w of res.data.list) {
        out.push(MessageItem.fromWire(w))
      }
      return out
    }
    return []
  }

  static currentSlot(): string {
    const h = new Date().getHours()
    if (h < 10) {
      return 'morning'
    }
    if (h < 14) {
      return 'noon'
    }
    if (h < 18) {
      return 'afternoon'
    }
    return 'evening'
  }

  static slotLabel(slot: string): string {
    if (slot === 'morning') {
      return '清晨'
    }
    if (slot === 'noon') {
      return '正午'
    }
    if (slot === 'evening') {
      return '晚间'
    }
    return '午后'
  }

  static recommend(drinks: DrinkItem[], feelTemp: number): DrinkItem | undefined {
    if (drinks.length === 0) {
      return undefined
    }
    const slot = DrinkBizService.currentSlot()
    let best: DrinkItem = drinks[0]
    let bestScore = -1
    for (const d of drinks) {
      let score = 0
      if (feelTemp >= d.tempMin && feelTemp <= d.tempMax) {
        score += 4
      }
      if (d.slot === slot) {
        score += 3
      }
      if (d.isHot) {
        score += 1
      }
      if (feelTemp >= 33 && (d.category === '冰饮' || d.category === '冰沙')) {
        score += 2
      }
      if (feelTemp <= 28 && d.category === '凉茶') {
        score += 2
      }
      if (score > bestScore) {
        bestScore = score
        best = d
      }
    }
    return best
  }

  static todayPick(drinks: DrinkItem[]): DrinkItem | undefined {
    if (drinks.length === 0) {
      return undefined
    }
    for (const d of drinks) {
      if (d.featured) {
        return d
      }
    }
    const idx = new Date().getDate() % drinks.length
    return drinks[idx]
  }

  static categories(): string[] {
    return ['冰饮', '果茶', '奶昔', '冰沙', '凉茶']
  }
}
