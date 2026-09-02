/** 运动类型视觉映射 — 列表封面渐变与标签色（非功能图标） */
export class SportVisual {
  static accentHex(type: string): string {
    if (type === '跑步') {
      return '#1A5CFF'
    }
    if (type === '骑行') {
      return '#10B981'
    }
    if (type === '健身') {
      return '#FF6B35'
    }
    if (type === '球类') {
      return '#8B5CF6'
    }
    if (type === '游泳') {
      return '#06B6D4'
    }
    return '#64748B'
  }

  static coverLabel(type: string): string {
    if (type === '跑步') {
      return 'RUN'
    }
    if (type === '骑行') {
      return 'RIDE'
    }
    if (type === '健身') {
      return 'GYM'
    }
    if (type === '球类') {
      return 'BALL'
    }
    if (type === '游泳') {
      return 'SWIM'
    }
    return 'GO'
  }

  static feelingTag(feeling: string): string {
    if (feeling.length === 0) {
      return '未填'
    }
    return feeling
  }

  static coverImage(type: string): Resource {
    if (type === '跑步' || type === '骑行' || type === '健身') {
      return $r('app.media.hero_sport_bg')
    }
    return $r('app.media.ambient_data_bg')
  }
}
