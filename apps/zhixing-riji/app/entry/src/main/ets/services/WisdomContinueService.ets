/** 智慧续写 — 规则模板辅助（非生成式大模型） */
export class WisdomSuggestion {
  hint: string = ''
  append: string = ''
}

export class WisdomContinueService {
  static suggest(body: string, mood: string, destination: string): WisdomSuggestion {
    const out = new WisdomSuggestion()
    const place = destination.trim().length > 0 ? destination.trim() : '这段旅途'
    const moodLine = WisdomContinueService.moodPhrase(mood)
    if (body.trim().length === 0) {
      out.hint = `已根据「${mood}」为你准备开篇句式，可继续修改`
      out.append = `${place}的第一缕风迎面而来，${moodLine}。`
      return out
    }
    if (body.length < 40) {
      out.hint = '续写建议已追加到正文末尾'
      out.append = `沿着${place}继续前行，${moodLine}，想把这一瞬留得更久一些。`
      return out
    }
    out.hint = '根据已有内容补充了收束句'
    out.append = `回望${place}，${moodLine}，这些片段会组成专属旅行地图上的又一颗标记。`
    return out
  }

  private static moodPhrase(mood: string): string {
    if (mood === '感动') {
      return '眼眶微热，却觉得值得'
    }
    if (mood === '宁静') {
      return '时间仿佛慢了下来'
    }
    if (mood === '兴奋') {
      return '脚步轻快，心跳与风景同频'
    }
    if (mood === '思念') {
      return '某些画面会与某人重叠'
    }
    return '心里是踏实而明亮的'
  }

  static moodOptions(): string[] {
    return ['开心', '感动', '宁静', '兴奋', '思念']
  }
}
