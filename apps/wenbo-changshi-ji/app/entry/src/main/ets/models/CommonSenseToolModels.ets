/** 清单 / 问答 / 收藏夹 / 提醒 / 消息 的本机模型 */

export class CsMsgWire {
  id: string = ''
  title: string = ''
  body: string = ''
}

export class CsMsgListPayload {
  list: CsMsgWire[] = []
}

export class FolderBind {
  factId: string = ''
  folder: string = ''
}

export class QuizOption {
  id: string = ''
  text: string = ''
  correct: boolean = false
}

export class QuizQuestion {
  factId: string = ''
  title: string = ''
  prompt: string = ''
  options: QuizOption[] = []
}

export class QuizResult {
  total: number = 0
  correct: number = 0
  wrongFactIds: string[] = []
}

export class ChecklistItem {
  id: string = ''
  title: string = ''
  learned: boolean = false
  remark: string = ''
  factId: string = ''
}

export class ChecklistDoc {
  id: string = ''
  title: string = ''
  createdAt: string = ''
  items: ChecklistItem[] = []

  learnedCount(): number {
    let n = 0
    for (const row of this.items) {
      if (row.learned) {
        n = n + 1
      }
    }
    return n
  }
}

export class RemindPref {
  enabled: boolean = false
  hour: number = 21
  minute: number = 0
  agentId: number = 0

  timeLabel(): string {
    const h = this.hour < 10 ? `0${this.hour}` : `${this.hour}`
    const m = this.minute < 10 ? `0${this.minute}` : `${this.minute}`
    return `${h}:${m}`
  }

  toJsonString(): string {
    return `{"enabled":${this.enabled},"hour":${this.hour},"minute":${this.minute},"agentId":${this.agentId}}`
  }
}
