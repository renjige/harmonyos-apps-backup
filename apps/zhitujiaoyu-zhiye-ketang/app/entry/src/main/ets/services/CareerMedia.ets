/**
 * 栏目封面映射 — 每个 category 对应独立 media 资源。
 */
export class CareerMedia {
  static cover(key: string, category: string = ''): Resource {
    const cat = category.length > 0 ? category : key
    if (key === 'cover_skill' || cat === '职场技能') {
      return $r('app.media.cover_skill')
    }
    if (key === 'cover_manage' || cat === '管理能力' || cat === '管理提升') {
      return $r('app.media.cover_manage')
    }
    if (key === 'cover_comm' || cat === '沟通表达' || cat === '沟通协作') {
      return $r('app.media.cover_comm')
    }
    if (key === 'cover_plan' || cat === '职业规划') {
      return $r('app.media.cover_plan')
    }
    if (key === 'hero_career' || cat === 'hero') {
      return $r('app.media.hero_career')
    }
    if (cat === '职业资讯' || cat === '学习方法') {
      return $r('app.media.cover_comm')
    }
    return $r('app.media.cover_career')
  }

  static hero(): Resource {
    return $r('app.media.hero_career')
  }
}
