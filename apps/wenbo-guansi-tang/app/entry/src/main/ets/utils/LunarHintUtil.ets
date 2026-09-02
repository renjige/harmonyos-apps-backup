/** 智慧日历辅助：公历星期 + 简易农历提示文案 */

import { CategoryEmojiUtil } from './CategoryEmojiUtil'

export class LunarHintUtil {
  static weekdayLabel(): string {
    const d = new Date().getDay()
    if (d === 0) {
      return '星期日'
    }
    if (d === 1) {
      return '星期一'
    }
    if (d === 2) {
      return '星期二'
    }
    if (d === 3) {
      return '星期三'
    }
    if (d === 4) {
      return '星期四'
    }
    if (d === 5) {
      return '星期五'
    }
    return '星期六'
  }

  static lunarHint(): string {
    const hints: string[] = [
      '宜静思 · 忌浮躁',
      '宜读书 · 忌空言',
      '宜内省 · 忌争锋',
      '宜慢读 · 忌赶工',
      '宜致良知 · 忌自欺',
      '宜留白 · 忌填满',
      '宜感恩 · 忌怨怼',
      '宜践行 · 忌空谈',
      '宜守常 · 忌多变',
      '宜温故 · 忌遗忘'
    ]
    const idx = new Date().getDate() % hints.length
    return hints[idx]
  }

  static todayLabel(): string {
    const d = new Date()
    const m = d.getMonth() + 1
    const day = d.getDate()
    const pad = day < 10 ? `0${day}` : `${day}`
    const mp = m < 10 ? `0${m}` : `${m}`
    return `${CategoryEmojiUtil.weekdayMark()} ${d.getFullYear()}年${mp}月${pad}日 · ${LunarHintUtil.weekdayLabel()}`
  }

  static moodHint(): string {
    return CategoryEmojiUtil.lunarHintWithMark()
  }
}
