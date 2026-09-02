/** coverKey → 影像资源与 Hero 渐变色 */
export class TaskMedia {
  static coverResource(key: string): Resource | undefined {
    if (key === 'hero_productivity') {
      return $r('app.media.hero_productivity')
    }
    if (key === 'banner_schedule') {
      return $r('app.media.banner_schedule')
    }
    if (key === 'cover_habit') {
      return $r('app.media.cover_habit')
    }
    if (key === 'banner_organize') {
      return $r('app.media.banner_organize')
    }
    return undefined
  }

  static heroGradient(key: string): string[] {
    if (key === 'hero_productivity') {
      return ['#2563EB', '#1E40AF']
    }
    if (key === 'banner_schedule') {
      return ['#2563EB', '#0EA5E9']
    }
    if (key === 'cover_habit') {
      return ['#22C55E', '#15803D']
    }
    if (key === 'banner_organize') {
      return ['#F97316', '#EA580C']
    }
    return ['#2563EB', '#1E3A8A']
  }

  static taskPriorityColor(priority: string): string {
    if (priority === 'high') {
      return '#F97316'
    }
    if (priority === 'low') {
      return '#64748B'
    }
    return '#2563EB'
  }
}
