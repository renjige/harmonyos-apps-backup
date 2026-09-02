/** 自驾游学 — 平台 Wire 与本地模型（ArkTS 严格模式） */

export class RouteStop {
  id: string = ''
  title: string = ''
  hours: string = ''
  spotId: string = ''
}

export class RouteWire {
  id: string = ''
  title: string = ''
  subtitle: string = ''
  status: string = ''
  summary: string = ''
  body: string = ''
  description: string = ''
  coverKey: string = ''
  coverMedia: string = ''
  tags: string[] = []
  theme: string = ''
  days: number = 0
  mileage: string = ''
  duration: string = ''
  ageRange: string = ''
  city: string = ''
  climateNote: string = ''
  stopsJson: string = ''
}

export class RouteItem {
  id: string = ''
  title: string = ''
  subtitle: string = ''
  summary: string = ''
  body: string = ''
  coverKey: string = ''
  tags: string[] = []
  theme: string = ''
  days: number = 0
  mileage: string = ''
  duration: string = ''
  ageRange: string = ''
  city: string = ''
  climateNote: string = ''
  stops: RouteStop[] = []

  static fromWire(w: RouteWire): RouteItem {
    const item = new RouteItem()
    item.id = w.id
    item.title = w.title
    item.subtitle = w.subtitle ?? ''
    item.summary = w.summary ?? ''
    item.body = w.body ?? w.description ?? ''
    if (w.coverKey.length > 0) {
      item.coverKey = w.coverKey
    } else if (w.coverMedia !== undefined && w.coverMedia.length > 0) {
      item.coverKey = w.coverMedia
    }
    item.tags = w.tags ?? []
    item.theme = w.theme ?? ''
    item.days = w.days ?? 0
    item.mileage = w.mileage ?? ''
    item.duration = w.duration ?? ''
    item.ageRange = w.ageRange ?? ''
    item.city = w.city ?? ''
    item.climateNote = w.climateNote ?? ''
    item.stops = RouteItem.parseStops(w.stopsJson ?? '')
    return item
  }

  static parseStops(raw: string): RouteStop[] {
    const out: RouteStop[] = []
    if (raw.length === 0) {
      return out
    }
    const lines = raw.split('\n')
    for (const line of lines) {
      const parts = line.split('||')
      const s = new RouteStop()
      let i = 0
      for (const p of parts) {
        if (i === 0) {
          s.id = p
        } else if (i === 1) {
          s.title = p
        } else if (i === 2) {
          s.hours = p
        } else if (i === 3) {
          s.spotId = p
        }
        i++
      }
      if (s.title.length > 0) {
        out.push(s)
      }
    }
    return out
  }

  themeLabel(): string {
    if (this.theme === 'nature') {
      return '自然探索'
    }
    if (this.theme === 'history') {
      return '历史文化'
    }
    if (this.theme === 'science') {
      return '科学启蒙'
    }
    if (this.theme === 'art') {
      return '艺术体验'
    }
    return '研学'
  }
}

export class RouteListPayload {
  list: RouteWire[] = []
}

export class SpotWire {
  id: string = ''
  title: string = ''
  subtitle: string = ''
  summary: string = ''
  body: string = ''
  description: string = ''
  coverKey: string = ''
  coverMedia: string = ''
  city: string = ''
  relatedRouteId: string = ''
  ageRange: string = ''
  knowledgeAge3: string = ''
  knowledgeAge7: string = ''
  knowledgeAge13: string = ''
}

export class SpotItem {
  id: string = ''
  title: string = ''
  subtitle: string = ''
  summary: string = ''
  body: string = ''
  coverKey: string = ''
  city: string = ''
  relatedRouteId: string = ''
  ageRange: string = ''
  knowledgeAge3: string = ''
  knowledgeAge7: string = ''
  knowledgeAge13: string = ''

  static fromWire(w: SpotWire): SpotItem {
    const item = new SpotItem()
    item.id = w.id
    item.title = w.title
    item.subtitle = w.subtitle ?? ''
    item.summary = w.summary ?? ''
    item.body = w.body ?? w.description ?? ''
    if (w.coverKey.length > 0) {
      item.coverKey = w.coverKey
    } else if (w.coverMedia !== undefined && w.coverMedia.length > 0) {
      item.coverKey = w.coverMedia
    }
    item.city = w.city ?? ''
    item.relatedRouteId = w.relatedRouteId ?? ''
    item.ageRange = w.ageRange ?? ''
    item.knowledgeAge3 = w.knowledgeAge3 ?? ''
    item.knowledgeAge7 = w.knowledgeAge7 ?? ''
    item.knowledgeAge13 = w.knowledgeAge13 ?? ''
    return item
  }
}

export class SpotListPayload {
  list: SpotWire[] = []
}

export class QuizWire {
  id: string = ''
  title: string = ''
  spotId: string = ''
  summary: string = ''
  questionsJson: string = ''
}

export class QuizQuestion {
  prompt: string = ''
  optionA: string = ''
  optionB: string = ''
  optionC: string = ''
  optionD: string = ''
  correctIndex: number = 0
  explain: string = ''
}

export class QuizItem {
  id: string = ''
  title: string = ''
  spotId: string = ''
  summary: string = ''
  questions: QuizQuestion[] = []

  static fromWire(w: QuizWire): QuizItem {
    const item = new QuizItem()
    item.id = w.id
    item.title = w.title
    item.spotId = w.spotId ?? ''
    item.summary = w.summary ?? ''
    item.questions = QuizItem.parseQuestions(w.questionsJson ?? '')
    return item
  }

  static parseQuestions(raw: string): QuizQuestion[] {
    const out: QuizQuestion[] = []
    if (raw.length === 0) {
      return out
    }
    const lines = raw.split('\n')
    for (const line of lines) {
      const parts = line.split('||')
      const q = new QuizQuestion()
      let i = 0
      for (const p of parts) {
        if (i === 0) {
          q.prompt = p
        } else if (i === 1) {
          q.optionA = p
        } else if (i === 2) {
          q.optionB = p
        } else if (i === 3) {
          q.optionC = p
        } else if (i === 4) {
          q.optionD = p
        } else if (i === 5) {
          q.correctIndex = Number.parseInt(p, 10)
        } else if (i === 6) {
          q.explain = p
        }
        i++
      }
      if (q.prompt.length > 0) {
        out.push(q)
      }
    }
    return out
  }
}

export class QuizListPayload {
  list: QuizWire[] = []
}

export class WeatherWire {
  id: string = ''
  title: string = ''
  city: string = ''
  season: string = ''
  tempRange: string = ''
  hint: string = ''
  summary: string = ''
  coverKey: string = ''
}

export class WeatherItem {
  id: string = ''
  title: string = ''
  city: string = ''
  season: string = ''
  tempRange: string = ''
  hint: string = ''
  summary: string = ''
  coverKey: string = ''

  static fromWire(w: WeatherWire): WeatherItem {
    const item = new WeatherItem()
    item.id = w.id
    item.title = w.title
    item.city = w.city ?? ''
    item.season = w.season ?? ''
    item.tempRange = w.tempRange ?? ''
    item.hint = w.hint ?? ''
    item.summary = w.summary ?? ''
    item.coverKey = w.coverKey ?? ''
    return item
  }
}

export class WeatherListPayload {
  list: WeatherWire[] = []
}

export class RecordWire {
  id: string = ''
  title: string = ''
  subtitle: string = ''
  summary: string = ''
  body: string = ''
  description: string = ''
  coverKey: string = ''
  startAt: string = ''
  endAt: string = ''
  itemsJson: string = ''
  remark: string = ''
  placeLabel: string = ''
  userId: string = ''
  spotId: string = ''
  routeId: string = ''
  targetKind: string = ''
  targetId: string = ''
  status: string = ''
  createdAt: string = ''
}

export class RecordItem {
  id: string = ''
  title: string = ''
  subtitle: string = ''
  summary: string = ''
  body: string = ''
  coverKey: string = ''
  startAt: string = ''
  endAt: string = ''
  itemsJson: string = ''
  remark: string = ''
  placeLabel: string = ''
  spotId: string = ''
  routeId: string = ''
  targetKind: string = ''
  targetId: string = ''
  status: string = ''
  createdAt: string = ''

  static fromWire(w: RecordWire): RecordItem {
    const item = new RecordItem()
    item.id = w.id
    item.title = w.title
    item.subtitle = w.subtitle ?? ''
    item.summary = w.summary ?? w.body ?? ''
    item.body = w.body ?? w.description ?? ''
    item.coverKey = w.coverKey ?? ''
    item.startAt = w.startAt ?? ''
    item.endAt = w.endAt ?? ''
    item.itemsJson = w.itemsJson ?? ''
    item.remark = w.remark ?? ''
    item.placeLabel = w.placeLabel ?? ''
    item.spotId = w.spotId ?? ''
    item.routeId = w.routeId ?? ''
    item.targetKind = w.targetKind ?? ''
    item.targetId = w.targetId ?? ''
    item.status = w.status ?? ''
    item.createdAt = w.createdAt ?? ''
    return item
  }
}

export class RecordListPayload {
  list: RecordWire[] = []
}

export class MessageWire {
  id: string = ''
  title: string = ''
  body: string = ''
  type: string = ''
  read: boolean = false
  createdAt: string = ''
}

export class MessageItem {
  id: string = ''
  title: string = ''
  body: string = ''
  createdAt: string = ''

  static fromWire(w: MessageWire): MessageItem {
    const item = new MessageItem()
    item.id = w.id
    item.title = w.title
    item.body = w.body ?? ''
    item.createdAt = w.createdAt ?? ''
    return item
  }
}

export class MessageListPayload {
  list: MessageWire[] = []
}

export class StudyWriteRequest {
  title: string = ''
  subtitle: string = ''
  summary: string = ''
  body: string = ''
  coverKey: string = ''
  startAt: string = ''
  endAt: string = ''
  itemsJson: string = ''
  remark: string = ''
  placeLabel: string = ''
  userId: string = ''
  spotId: string = ''
  routeId: string = ''
  targetKind: string = ''
  targetId: string = ''
  status: string = ''

  toJsonString(): string {
    return `{"title":${JSON.stringify(this.title)},"subtitle":${JSON.stringify(this.subtitle)},` +
      `"summary":${JSON.stringify(this.summary)},"body":${JSON.stringify(this.body)},` +
      `"coverKey":${JSON.stringify(this.coverKey)},"startAt":${JSON.stringify(this.startAt)},` +
      `"endAt":${JSON.stringify(this.endAt)},"itemsJson":${JSON.stringify(this.itemsJson)},` +
      `"remark":${JSON.stringify(this.remark)},"placeLabel":${JSON.stringify(this.placeLabel)},` +
      `"userId":${JSON.stringify(this.userId)},"spotId":${JSON.stringify(this.spotId)},` +
      `"routeId":${JSON.stringify(this.routeId)},"targetKind":${JSON.stringify(this.targetKind)},` +
      `"targetId":${JSON.stringify(this.targetId)},"status":${JSON.stringify(this.status)}}`
  }
}
