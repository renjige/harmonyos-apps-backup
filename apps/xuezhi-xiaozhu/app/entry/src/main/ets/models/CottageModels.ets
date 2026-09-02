/** 学知小筑 — 平台 /biz/study-cottage 模型 */

export class CottageItem {
  id: string = ''
  title: string = ''
  subtitle: string = ''
  summary: string = ''
  body: string = ''
  description: string = ''
  coverKey: string = ''
  category: string = ''
  categoryLabel: string = ''
  tags: string = ''
  pathId: string = ''
  domain: string = ''
  days: number = 0
  minutes: number = 0
  difficulty: string = ''
  keywords: string = ''
  disclaimer: string = ''
  lessonId: string = ''
  cardId: string = ''
  minutesLogged: number = 0
  sortOrder: number = 0
  createdAt: string = ''
}

export class CottageListData {
  list: CottageItem[] = []
  disclaimer: string = ''
}

export class CottageKpi {
  key: string = ''
  label: string = ''
  value: string = ''
}

export class CottageKpiPayload {
  list: CottageKpi[] = []
}

export class CottageMessage {
  id: string = ''
  title: string = ''
  body: string = ''
  createdAt: string = ''
}

export class CottageMsgPayload {
  list: CottageMessage[] = []
}

export class CottageWriteBody {
  userId: string = ''
  lessonId: string = ''
  pathId: string = ''
  cardId: string = ''
  title: string = ''
  minutesLogged: number = 0

  toJsonString(): string {
    return `{"userId":${JSON.stringify(this.userId)},"lessonId":${JSON.stringify(this.lessonId)},"pathId":${JSON.stringify(this.pathId)},"cardId":${JSON.stringify(this.cardId)},"title":${JSON.stringify(this.title)},"minutesLogged":${this.minutesLogged}}`
  }
}
