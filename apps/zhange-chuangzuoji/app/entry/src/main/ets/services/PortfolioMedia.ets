export class PortfolioMedia {
  static coverResource(key: string): Resource {
    if (key === 'banner_curate') {
      return $r('app.media.banner_curate')
    }
    if (key === 'cat_ui') {
      return $r('app.media.cat_ui')
    }
    if (key === 'cat_illustration') {
      return $r('app.media.cat_illustration')
    }
    if (key === 'cat_photo') {
      return $r('app.media.cat_photo')
    }
    if (key === 'case_dev') {
      return $r('app.media.case_dev')
    }
    return $r('app.media.hero_studio')
  }

  static categoryLabel(category: string): string {
    if (category === 'ui') {
      return 'UI设计'
    }
    if (category === 'illustration') {
      return '插画'
    }
    if (category === 'photo') {
      return '摄影'
    }
    if (category === 'dev') {
      return '开发项目'
    }
    return '其他'
  }

  static coverKeys(): string[] {
    return ['hero_studio', 'banner_curate', 'cat_ui', 'cat_illustration', 'cat_photo', 'case_dev']
  }
}
