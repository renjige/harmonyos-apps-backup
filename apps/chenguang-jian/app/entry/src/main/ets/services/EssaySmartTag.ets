/** 智慧标签：词表规则匹配，非生成式模型 */

export class EssaySmartTag {
  static suggest(content: string, extra: string): string[] {
    const text = `${content} ${extra}`
    const out: string[] = []
    EssaySmartTag.pushIf(out, text, '晨光', ['晨光', '清晨', '日出', '朝阳', '天亮'])
    EssaySmartTag.pushIf(out, text, '一念', ['忽然', '想起', '念头', '灵感', '一闪'])
    EssaySmartTag.pushIf(out, text, '生活', ['生活', '日常', '家里', '做饭', '散步'])
    EssaySmartTag.pushIf(out, text, '工作', ['工作', '会议', '项目', '上班', '同事'])
    EssaySmartTag.pushIf(out, text, '阅读', ['阅读', '书', '诗', '句子', '页'])
    EssaySmartTag.pushIf(out, text, '旅途', ['旅途', '车站', '飞机', '路上', '远方'])
    EssaySmartTag.pushIf(out, text, '家人', ['家人', '妈妈', '爸爸', '孩子', '家里人'])
    EssaySmartTag.pushIf(out, text, '季节', ['春', '夏', '秋', '冬', '节气'])
    EssaySmartTag.pushIf(out, text, '天气', ['雨', '风', '晴', '雾', '雪', '阴'])
    return out
  }

  private static pushIf(out: string[], text: string, tag: string, keys: string[]): void {
    for (const k of keys) {
      if (text.indexOf(k) >= 0) {
        let exists = false
        for (const t of out) {
          if (t === tag) {
            exists = true
          }
        }
        if (!exists) {
          out.push(tag)
        }
        return
      }
    }
  }

  static merge(user: string[], suggested: string[]): string[] {
    const out: string[] = []
    for (const t of user) {
      if (t.length > 0) {
        out.push(t)
      }
    }
    for (const t of suggested) {
      let exists = false
      for (const u of out) {
        if (u === t) {
          exists = true
        }
      }
      if (!exists) {
        out.push(t)
      }
    }
    return out
  }

  static csv(tags: string[]): string {
    let s = ''
    for (let i = 0; i < tags.length; i++) {
      if (i > 0) {
        s = `${s},`
      }
      s = `${s}${tags[i]}`
    }
    return s
  }
}
