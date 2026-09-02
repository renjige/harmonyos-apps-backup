/** 专题路线：把相关卡片串成可执行阅读路径（本机进度） */
export class ReadingTrail {
  id: string = ''
  title: string = ''
  subtitle: string = ''
  cardIds: string[] = []
  practiceKind: string = 'review'
  coverKey: string = 'cover_biz_01'

  stepCount(): number {
    return this.cardIds.length
  }
}

export class AtelierTrails {
  static all(): ReadingTrail[] {
    const list: ReadingTrail[] = []
    list.push(AtelierTrails.make('trail_biz', '商业沟通三篇', '会议 · 报价 · 邮件', ['yz_card_01', 'yz_card_02', 'yz_card_11'], 'review', 'cover_biz_01'))
    list.push(AtelierTrails.make('trail_hum', '人文笔记两读', '会讲 · 余味 · 批注', ['yz_card_03', 'yz_card_04', 'yz_card_17'], 'aftertaste', 'cover_hum_01'))
    list.push(AtelierTrails.make('trail_tech', '数字习惯重建', '通知 · 规则 · 密码', ['yz_card_05', 'yz_card_06', 'yz_card_18'], 'whitelist', 'cover_tech_01'))
    list.push(AtelierTrails.make('trail_life', '生活微行动', '散步 · 计时 · 睡眠', ['yz_card_07', 'yz_card_08', 'yz_card_19'], 'walk', 'cover_life_01'))
    list.push(AtelierTrails.make('trail_art', '观看与排版', '临摹 · 字体 · 声音', ['yz_card_09', 'yz_card_10', 'yz_card_20'], 'sketch', 'cover_art_01'))
    return list
  }

  static find(id: string): ReadingTrail | undefined {
    for (const row of AtelierTrails.all()) {
      if (row.id === id) {
        return row
      }
    }
    return undefined
  }

  static practiceLabel(kind: string): string {
    if (kind === 'aftertaste') {
      return '余味札'
    }
    if (kind === 'whitelist') {
      return '通知白名单'
    }
    if (kind === 'walk') {
      return '同一条路'
    }
    if (kind === 'sketch') {
      return '临摹三记'
    }
    return '三问检修'
  }

  private static make(id: string, title: string, subtitle: string, cardIds: string[], kind: string,
    cover: string): ReadingTrail {
    const row = new ReadingTrail()
    row.id = id
    row.title = title
    row.subtitle = subtitle
    row.cardIds = cardIds
    row.practiceKind = kind
    row.coverKey = cover
    return row
  }
}
