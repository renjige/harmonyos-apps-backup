/** coverKey → app.media 资源；一 key 一图，禁止 fallback 共图 */
export class CraftMedia {
  static heroBg(): Resource {
    return $r('app.media.hero_bg')
  }

  static byKey(key: string): Resource {
    if (key === 'cover_work_1' || key === 'work_1') {
      return $r('app.media.cover_work_1')
    }
    if (key === 'cover_work_2' || key === 'work_2') {
      return $r('app.media.cover_work_2')
    }
    if (key === 'cover_work_3' || key === 'work_3') {
      return $r('app.media.cover_work_3')
    }
    if (key === 'cover_work_4' || key === 'work_4') {
      return $r('app.media.cover_work_4')
    }
    if (key === 'cover_work_5' || key === 'work_5') {
      return $r('app.media.cover_work_5')
    }
    if (key === 'cover_work_6' || key === 'work_6') {
      return $r('app.media.cover_work_6')
    }
    if (key === 'cover_work_7' || key === 'work_7') {
      return $r('app.media.cover_work_7')
    }
    if (key === 'cover_work_8' || key === 'work_8') {
      return $r('app.media.cover_work_8')
    }
    if (key === 'hero_bg') {
      return CraftMedia.heroBg()
    }
    return $r('app.media.cover_work_1')
  }

  static coverOptions(): string[] {
    const opts: string[] = []
    opts.push('cover_work_1')
    opts.push('cover_work_2')
    opts.push('cover_work_3')
    opts.push('cover_work_4')
    opts.push('cover_work_5')
    opts.push('cover_work_6')
    opts.push('cover_work_7')
    opts.push('cover_work_8')
    return opts
  }

  static coverLabel(key: string): string {
    if (key === 'cover_work_1') {
      return '纸艺扉页'
    }
    if (key === 'cover_work_2') {
      return '编织杯垫'
    }
    if (key === 'cover_work_3') {
      return '陶艺花器'
    }
    if (key === 'cover_work_4') {
      return '刺绣书签'
    }
    if (key === 'cover_work_5') {
      return '木工支架'
    }
    if (key === 'cover_work_6') {
      return '香薰蜡烛'
    }
    if (key === 'cover_work_7') {
      return '押花相框'
    }
    if (key === 'cover_work_8') {
      return '皮具卡包'
    }
    return '默认封面'
  }

  static defaultCoverForCategory(category: string): string {
    if (category === '纸艺') {
      return 'cover_work_1'
    }
    if (category === '编织') {
      return 'cover_work_2'
    }
    if (category === '陶艺') {
      return 'cover_work_3'
    }
    if (category === '刺绣') {
      return 'cover_work_4'
    }
    if (category === '木工') {
      return 'cover_work_5'
    }
    if (category === '蜡烛') {
      return 'cover_work_6'
    }
    if (category === '植物') {
      return 'cover_work_7'
    }
    if (category === '皮具') {
      return 'cover_work_8'
    }
    return 'cover_work_1'
  }

  static categoryTint(category: string): string {
    if (category === '纸艺') {
      return '#E8DDD4'
    }
    if (category === '编织') {
      return '#DDD8E8'
    }
    if (category === '陶艺') {
      return '#D4C4B0'
    }
    if (category === '刺绣') {
      return '#E4D4D8'
    }
    if (category === '木工') {
      return '#D8CFC0'
    }
    if (category === '蜡烛') {
      return '#EDE4D0'
    }
    if (category === '植物') {
      return '#D8E4D0'
    }
    if (category === '皮具') {
      return '#D0C8BC'
    }
    return '#F0EBE3'
  }
}
