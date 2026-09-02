export class ObserveAlbum {
  id: string = ''
  title: string = ''
  createdAt: number = 0
  essayIdsCsv: string = ''

  static create(title: string): ObserveAlbum {
    const a = new ObserveAlbum()
    a.id = `alb_${Date.now()}_${Math.floor(Math.random() * 10000)}`
    a.title = title.trim()
    a.createdAt = Date.now()
    return a
  }

  essayIds(): string[] {
    return ObserveAlbum.splitCsv(this.essayIdsCsv)
  }

  contains(essayId: string): boolean {
    const ids = this.essayIds()
    for (const id of ids) {
      if (id === essayId) {
        return true
      }
    }
    return false
  }

  addEssay(essayId: string): void {
    if (this.contains(essayId) || essayId.length === 0) {
      return
    }
    const ids = this.essayIds()
    ids.push(essayId)
    this.essayIdsCsv = ids.join(',')
  }

  removeEssay(essayId: string): void {
    const next: string[] = []
    const ids = this.essayIds()
    for (const id of ids) {
      if (id !== essayId) {
        next.push(id)
      }
    }
    this.essayIdsCsv = next.join(',')
  }

  static splitCsv(csv: string): string[] {
    const out: string[] = []
    if (csv.length === 0) {
      return out
    }
    const parts = csv.split(',')
    for (const p of parts) {
      if (p.length > 0) {
        out.push(p)
      }
    }
    return out
  }
}

export class ObserveTheme {
  id: string = ''
  title: string = ''
  senseKey: string = ''
  targetCount: number = 7
  startKey: string = ''
  endKey: string = ''
  status: string = 'active'
  createdAt: number = 0

  static create(title: string, senseKey: string, targetCount: number, startKey: string, endKey: string): ObserveTheme {
    const t = new ObserveTheme()
    t.id = `thm_${Date.now()}_${Math.floor(Math.random() * 10000)}`
    t.title = title.trim()
    t.senseKey = senseKey
    t.targetCount = targetCount < 1 ? 1 : targetCount
    t.startKey = startKey
    t.endKey = endKey
    t.status = 'active'
    t.createdAt = Date.now()
    return t
  }

  isActive(): boolean {
    return this.status === 'active'
  }
}

export class ObserveBadge {
  id: string = ''
  title: string = ''
  hint: string = ''
  unlockedAt: number = 0

  unlocked(): boolean {
    return this.unlockedAt > 0
  }

  static catalog(): ObserveBadge[] {
    const ids: string[] = ['first_card', 'first_contrast', 'streak_7', 'fav_10', 'theme_done', 'all_senses']
    const titles: string[] = ['第一张观察卡', '第一次对照', '连续观察 7 天', '珍藏 10 篇', '完成一个专题', '七感都写过']
    const hints: string[] = [
      '用五感填空卡保存一篇',
      '并排两篇旧观察并写下这次不同',
      '连续 7 天都有观察记录',
      '珍藏满 10 篇观察',
      '把一个观察专题写到目标篇数',
      '光影、声音、气味、触感、颜色、人物、空白各至少一篇'
    ]
    const out: ObserveBadge[] = []
    for (let i = 0; i < ids.length; i++) {
      const b = new ObserveBadge()
      b.id = ids[i]
      b.title = titles[i]
      b.hint = hints[i]
      out.push(b)
    }
    return out
  }
}

export class ObserveEvent {
  id: string = ''
  dateKey: string = ''
  at: number = 0
  type: string = ''
  essayId: string = ''
  title: string = ''
}

export class SenseCount {
  key: string = ''
  label: string = ''
  count: number = 0
}

export class DayCount {
  label: string = ''
  count: number = 0
}
