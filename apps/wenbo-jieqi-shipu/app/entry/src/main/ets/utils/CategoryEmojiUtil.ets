/**
 * 节气 / 食材 / 功效 Emoji — 仅用于文案与标签点缀，不替代 AppIcon。
 */
export class CategoryEmojiUtil {
  static markForSolarTerm(name: string): string {
    if (name === '立春') return '🌱'
    if (name === '雨水') return '💧'
    if (name === '惊蛰') return '⚡'
    if (name === '春分') return '🌸'
    if (name === '清明') return '🍃'
    if (name === '谷雨') return '🌾'
    if (name === '立夏') return '☀️'
    if (name === '小满') return '🌿'
    if (name === '芒种') return '🌾'
    if (name === '夏至') return '🍜'
    if (name === '小暑') return '🍉'
    if (name === '大暑') return '🧊'
    if (name === '立秋') return '🍂'
    if (name === '处暑') return '🍐'
    if (name === '白露') return '🌾'
    if (name === '秋分') return '🦀'
    if (name === '寒露') return '🍎'
    if (name === '霜降') return '🌰'
    if (name === '立冬') return '🥟'
    if (name === '小雪') return '❄️'
    if (name === '大雪') return '⛄'
    if (name === '冬至') return '🍡'
    if (name === '小寒') return '🍲'
    if (name === '大寒') return '🔥'
    return '🍽'
  }

  static chipLabelSolarTerm(name: string): string {
    if (name.length === 0 || name === '全部') {
      return '🍽 全部'
    }
    return `${CategoryEmojiUtil.markForSolarTerm(name)} ${name}`
  }

  static markForIngredient(type: string): string {
    if (type === '谷物') return '🌾'
    if (type === '蔬菜') return '🥬'
    if (type === '肉类') return '🥩'
    if (type === '水产') return '🐟'
    if (type === '水果') return '🍎'
    return '🍽'
  }

  static chipLabelIngredient(type: string): string {
    if (type.length === 0 || type === '全部食材') {
      return '🍽 全部食材'
    }
    return `${CategoryEmojiUtil.markForIngredient(type)} ${type}`
  }

  static markForEffect(effect: string): string {
    if (effect === '润燥') return '💧'
    if (effect === '祛湿') return '🍃'
    if (effect === '温补') return '🔥'
    if (effect === '清热') return '❄️'
    return '✨'
  }

  static chipLabelEffect(effect: string): string {
    if (effect.length === 0 || effect === '全部功效') {
      return '✨ 全部功效'
    }
    return `${CategoryEmojiUtil.markForEffect(effect)} ${effect}`
  }

  static dietHint(): string {
    const hints: string[] = [
      '🍃 宜清淡 · 忌过饱',
      '🌾 宜当季 · 忌反季',
      '💧 宜温润 · 忌生冷',
      '🔥 宜温养 · 忌贪凉',
      '🥬 宜多样 · 忌单一',
      '🍲 宜慢食 · 忌赶工'
    ]
    const idx = new Date().getDate() % hints.length
    return hints[idx]
  }

  static weekdayMark(): string {
    const d = new Date().getDay()
    if (d === 0 || d === 6) return '🌤'
    if (d === 1) return '🌅'
    if (d === 5) return '🌙'
    return '☕'
  }
}
