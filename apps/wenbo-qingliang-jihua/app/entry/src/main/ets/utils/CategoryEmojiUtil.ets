/**
 * 文案 Emoji — 仅用于标签/空态/问候点缀，不替代 AppIcon。
 */
export class CategoryEmojiUtil {
  static moodMark(mood: string): string {
    if (mood === '平静') {
      return '🍃'
    }
    if (mood === '愉悦') {
      return '😊'
    }
    if (mood === '疲惫') {
      return '😴'
    }
    if (mood === '焦虑') {
      return '🌧'
    }
    if (mood === '专注') {
      return '🎯'
    }
    return '🌿'
  }

  static moodChip(mood: string): string {
    return `${CategoryEmojiUtil.moodMark(mood)} ${mood}`
  }

  static weekdayMark(): string {
    const d = new Date().getDay()
    if (d === 0 || d === 6) {
      return '🌤'
    }
    if (d === 1) {
      return '🌅'
    }
    if (d === 5) {
      return '🌙'
    }
    return '☕'
  }

  static dailyHint(): string {
    const hints: string[] = [
      '🍃 宜静息 · 忌心浮',
      '🌿 宜慢呼吸 · 忌赶工',
      '💭 宜写心语 · 忌空转',
      '🧘 宜专注 · 忌分心',
      '🌊 宜留白 · 忌填满',
      '✨ 宜感恩 · 忌怨怼',
      '📖 宜读一句 · 忌刷屏',
      '🪷 宜内观 · 忌争锋'
    ]
    return hints[new Date().getDate() % hints.length]
  }
}
