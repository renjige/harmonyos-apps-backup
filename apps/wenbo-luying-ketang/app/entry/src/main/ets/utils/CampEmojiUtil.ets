/**
 * 露营场景 / 难度 Emoji — 仅用于文案与标签点缀，不替代 AppIcon。
 */
export class CampEmojiUtil {
  static sceneMark(scene: string): string {
    if (scene === '全部') {
      return '📚'
    }
    if (scene === '亲子露营') {
      return '👨‍👩‍👧'
    }
    if (scene === 'solo露营') {
      return '🎒'
    }
    if (scene === '团队露营') {
      return '⛺'
    }
    return '🌲'
  }

  static levelMark(level: string): string {
    if (level === '全部') {
      return '🏷'
    }
    if (level === '入门') {
      return '🌱'
    }
    if (level === '进阶') {
      return '🔥'
    }
    if (level === '专业') {
      return '🏔'
    }
    return '📖'
  }

  static chipLabel(prefix: string, label: string): string {
    return `${prefix} ${label}`
  }

  static sceneChip(scene: string): string {
    return CampEmojiUtil.chipLabel(CampEmojiUtil.sceneMark(scene), scene)
  }

  static levelChip(level: string): string {
    return CampEmojiUtil.chipLabel(CampEmojiUtil.levelMark(level), level)
  }

  static progressHint(pct: number): string {
    if (pct >= 80) {
      return '🏅 即将满课'
    }
    if (pct >= 40) {
      return '📈 继续加油'
    }
    if (pct > 0) {
      return '🌿 已起步'
    }
    return '✨ 从第一节课开始'
  }

  static tripHint(): string {
    return '🗺 出发前记得核对装备清单'
  }

  static communityHint(): string {
    return '💬 分享你的露营笔记与装备心得'
  }
}
