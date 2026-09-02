/**
 * 文案 Emoji — 仅用于标签/空态/问候点缀，不替代 AppIcon。
 */
export class CategoryEmojiUtil {
  static moodMark(key: string): string {
    if (key === 'great') {
      return '😊'
    }
    if (key === 'good') {
      return '🙂'
    }
    if (key === 'ok') {
      return '😐'
    }
    if (key === 'low') {
      return '😔'
    }
    if (key === 'bad') {
      return '😢'
    }
    return '🌿'
  }

  static moodChip(key: string, label: string): string {
    return `${CategoryEmojiUtil.moodMark(key)} ${label}`
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
      '🌿 宜慢呼吸 · 忌心浮',
      '💛 宜写心情 · 忌空转',
      '🧘 宜专注 · 忌分心',
      '🌊 宜留白 · 忌填满',
      '✨ 宜感恩 · 忌怨怼',
      '📖 宜读一句 · 忌刷屏',
      '🪷 宜内观 · 忌争锋',
      '🕯 宜休息 · 忌硬撑'
    ]
    return hints[new Date().getDate() % hints.length]
  }
}
