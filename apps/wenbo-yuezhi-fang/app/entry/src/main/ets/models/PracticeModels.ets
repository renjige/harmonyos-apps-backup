/** 个人工坊课业（仅本机，非公开社区） */

export class PracticeItem {
  id: string = ''
  kind: string = 'review'
  cardId: string = ''
  title: string = ''
  fieldA: string = ''
  fieldB: string = ''
  fieldC: string = ''
  minutes: number = 0
  dateKey: string = ''

  static of(id: string, kind: string, cardId: string, title: string, a: string, b: string, c: string,
    minutes: number, dateKey: string): PracticeItem {
    const item = new PracticeItem()
    item.id = id
    item.kind = kind
    item.cardId = cardId
    item.title = title
    item.fieldA = a
    item.fieldB = b
    item.fieldC = c
    item.minutes = minutes
    item.dateKey = dateKey
    return item
  }

  kindLabel(): string {
    if (this.kind === 'review') {
      return '三问检修'
    }
    if (this.kind === 'aftertaste') {
      return '余味札'
    }
    if (this.kind === 'whitelist') {
      return '通知白名单'
    }
    if (this.kind === 'walk') {
      return '同一条路'
    }
    if (this.kind === 'sketch') {
      return '临摹三记'
    }
    if (this.kind === 'focus') {
      return '专注计时'
    }
    return '工坊课业'
  }

  preview(): string {
    if (this.fieldA.length > 0) {
      return this.fieldA
    }
    if (this.fieldB.length > 0) {
      return this.fieldB
    }
    return this.fieldC
  }

  toJsonString(): string {
    return `{"id":${JSON.stringify(this.id)},"kind":${JSON.stringify(this.kind)},` +
      `"cardId":${JSON.stringify(this.cardId)},"title":${JSON.stringify(this.title)},` +
      `"fieldA":${JSON.stringify(this.fieldA)},"fieldB":${JSON.stringify(this.fieldB)},` +
      `"fieldC":${JSON.stringify(this.fieldC)},"minutes":${this.minutes},` +
      `"dateKey":${JSON.stringify(this.dateKey)}}`
  }
}

export class PracticeKind {
  static ofCategory(category: string): string {
    if (category === 'business') {
      return 'review'
    }
    if (category === 'humanity') {
      return 'aftertaste'
    }
    if (category === 'tech') {
      return 'whitelist'
    }
    if (category === 'art') {
      return 'sketch'
    }
    return 'walk'
  }

  static ofDaily(id: string): string {
    if (id === 'yz_day_01') {
      return 'review'
    }
    if (id === 'yz_day_02') {
      return 'aftertaste'
    }
    if (id === 'yz_day_03') {
      return 'whitelist'
    }
    if (id === 'yz_day_04') {
      return 'walk'
    }
    return 'review'
  }

  static coverOf(kind: string): string {
    if (kind === 'review') {
      return 'cover_biz_01'
    }
    if (kind === 'aftertaste') {
      return 'cover_hum_02'
    }
    if (kind === 'whitelist') {
      return 'cover_tech_01'
    }
    if (kind === 'walk') {
      return 'cover_life_01'
    }
    if (kind === 'sketch') {
      return 'cover_art_01'
    }
    return 'cover_life_02'
  }

  static hintOf(kind: string): string {
    if (kind === 'review') {
      return '做成了什么 / 卡住了什么 / 下周只改一件'
    }
    if (kind === 'aftertaste') {
      return '抄一句，再写下它此刻为何打动你'
    }
    if (kind === 'whitelist') {
      return '默认关闭，只打开真正不能错过的几类'
    }
    if (kind === 'walk') {
      return '固定同一条路，先让身体出门'
    }
    if (kind === 'sketch') {
      return '线条、留白、此刻感受，各写一行'
    }
    return '选定时长，读完再写一句收获'
  }
}
