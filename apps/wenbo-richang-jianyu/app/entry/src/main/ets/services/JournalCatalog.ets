/** 心情 / 生活场景 / 今日笺题（规则轮换，非生成式 AI） */

export class JournalChoice {
  id: string = ''
  label: string = ''

  constructor(id: string, label: string) {
    this.id = id
    this.label = label
  }
}

/** 生活场景模板：一键带入写一页（非假数据，仅预填创作框架） */
export class JournalScenario {
  id: string = ''
  title: string = ''
  hint: string = ''
  scene: string = ''
  mood: string = ''
  tagName: string = ''
  bodyHint: string = ''

  constructor(id: string, title: string, hint: string, scene: string, mood: string, tagName: string, bodyHint: string) {
    this.id = id
    this.title = title
    this.hint = hint
    this.scene = scene
    this.mood = mood
    this.tagName = tagName
    this.bodyHint = bodyHint
  }
}

export class JournalCatalog {
  static moods(): JournalChoice[] {
    return [
      new JournalChoice('calm', '平静'),
      new JournalChoice('joy', '欢喜'),
      new JournalChoice('miss', '想念'),
      new JournalChoice('heal', '治愈'),
      new JournalChoice('tired', '疲惫'),
      new JournalChoice('hope', '期待')
    ]
  }

  static scenes(): JournalChoice[] {
    return [
      new JournalChoice('morning', '晨间'),
      new JournalChoice('commute', '通勤'),
      new JournalChoice('table', '餐桌'),
      new JournalChoice('walk', '散步'),
      new JournalChoice('night', '睡前'),
      new JournalChoice('weekend', '周末')
    ]
  }

  static scenarios(): JournalScenario[] {
    return [
      new JournalScenario('travel', '旅行见闻', '路上的风景与人', 'walk', 'joy', '旅行',
        '今天去了哪里？最难忘的一幕是……'),
      new JournalScenario('food', '餐桌味道', '记录一餐的温度', 'table', 'calm', '美食',
        '今天吃了什么？味道、香气、一起用餐的人……'),
      new JournalScenario('family', '家庭时刻', '与家人在一起的片段', 'weekend', 'heal', '家庭',
        '今天和家人发生了什么小事？'),
      new JournalScenario('workday', '通勤复盘', '把工作日轻轻收起', 'commute', 'tired', '照片',
        '今天工作中印象最深的一件事是……'),
      new JournalScenario('night_mood', '睡前心情', '给今天一个句号', 'night', 'calm', '',
        '此刻的心情是……今天最想感谢的是……'),
      new JournalScenario('weekend_plan', '周末计划', '把想做的事写下来', 'weekend', 'hope', '',
        '这个周末我想完成……'),
      new JournalScenario('reading', '阅读札记', '把读到的好句子留下', 'night', 'calm', '阅读',
        '今天读到了什么？哪一段话触动了你？'),
      new JournalScenario('exercise', '运动记录', '记录身体与心情的变化', 'walk', 'joy', '运动',
        '今天做了什么运动？身体感觉如何？'),
      new JournalScenario('gratitude', '感恩三件事', '发现日常里的小确幸', 'table', 'heal', '',
        '今天值得感谢的三件小事是……'),
      new JournalScenario('hobby', '兴趣时光', '投入热爱的一小时', 'weekend', 'joy', '兴趣',
        '今天为兴趣做了什么？过程里有什么新发现？'),
      new JournalScenario('reunion', '相聚时刻', '与人相处的温暖片段', 'table', 'heal', '家庭',
        '今天见了谁？说了什么让你会心一笑的话？'),
      new JournalScenario('weather', '天气心情', '用天气记录情绪底色', 'commute', 'calm', '',
        '今天的天气像什么？你的心情与之呼应吗？')
    ]
  }

  static weeklyChallenge(): string {
    const challenges: string[] = [
      '本周挑战：连续 5 天记录一件感恩的小事',
      '本周挑战：用 3 种不同场景模板各写一页',
      '本周挑战：完成一个生活计划并勾选全部任务',
      '本周挑战：坚持 7 天习惯打卡',
      '本周挑战：收藏 3 条触动你的语句',
      '本周挑战：创建一本相册时光册'
    ]
    const week = Math.floor(Date.now() / (7 * 24 * 3600 * 1000))
    const idx = week % challenges.length
    let i = 0
    for (const c of challenges) {
      if (i === idx) {
        return c
      }
      i += 1
    }
    return challenges[0]
  }

  static applyScenarioPrefill(s: JournalScenario, dateIso: string): void {
    AppStorage.setOrCreate('journalPrefillScene', s.scene)
    AppStorage.setOrCreate('journalPrefillMood', s.mood)
    AppStorage.setOrCreate('journalPrefillTitle', s.title)
    AppStorage.setOrCreate('journalPrefillBody', s.bodyHint)
    AppStorage.setOrCreate('journalPrefillTag', s.tagName)
    AppStorage.setOrCreate('journalPrefillDate', dateIso)
  }

  static triggerScenarioWrite(): void {
    AppStorage.setOrCreate('pendingTab', 3)
    AppStorage.setOrCreate('pendingWriteDiary', Date.now())
  }

  static findScenario(id: string): JournalScenario | undefined {
    for (const s of JournalCatalog.scenarios()) {
      if (s.id === id) {
        return s
      }
    }
    return undefined
  }

  static moodLabel(id: string): string {
    for (const m of JournalCatalog.moods()) {
      if (m.id === id) {
        return m.label
      }
    }
    return ''
  }

  static sceneLabel(id: string): string {
    for (const s of JournalCatalog.scenes()) {
      if (s.id === id) {
        return s.label
      }
    }
    return ''
  }

  static coverForScene(sceneId: string): string {
    if (sceneId === 'morning') {
      return 'hero_morning_coffee'
    }
    if (sceneId === 'commute') {
      return 'hero_rain_walk'
    }
    if (sceneId === 'table') {
      return 'hero_kitchen'
    }
    if (sceneId === 'walk') {
      return 'album_city_walk'
    }
    if (sceneId === 'night') {
      return 'hero_plants'
    }
    if (sceneId === 'weekend') {
      return 'hero_bookstore'
    }
    return 'hero_morning_coffee'
  }

  static promptForDate(iso: string): string {
    const prompts: string[] = [
      '今天有哪件小事，值得写成一句话？',
      '此刻窗边的光，像什么颜色？',
      '有谁的一句闲话，想收藏下来？',
      '今天的第一口食物，味道如何？',
      '走路时看见了什么被忽略的细节？',
      '今晚想轻轻放下的一件事是？',
      '给明天的自己留一句温暖的话。'
    ]
    let idx = 0
    if (iso.length >= 10) {
      const dayText = iso.substring(8, 10)
      const dayNum = parseInt(dayText, 10)
      if (!isNaN(dayNum) && dayNum > 0) {
        idx = (dayNum - 1) % prompts.length
      }
    }
    let i = 0
    for (const p of prompts) {
      if (i === idx) {
        return p
      }
      i += 1
    }
    return '今天有哪件小事，值得写成一句话？'
  }

  static cloudMediaKey(key: string): string {
    if (key.length === 0) {
      return 'hero_morning_coffee'
    }
    if (key.startsWith('local:')) {
      return 'hero_morning_coffee'
    }
    return key
  }
}
