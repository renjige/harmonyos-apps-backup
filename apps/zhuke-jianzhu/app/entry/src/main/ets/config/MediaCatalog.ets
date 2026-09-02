/** 筑科建筑 — 内容影像资源目录；imageKey / coverKey 与 MockData 对齐 */
export class MediaCatalog {
  static heroBg(): Resource {
    return $r('app.media.hero_bg')
  }

  static byKey(key: string): Resource {
    if (key === 'hero_bg') {
      return MediaCatalog.heroBg()
    }
    if (key === 'banner_landmark') {
      return $r('app.media.banner_landmark')
    }
    if (key === 'banner_municipal') {
      return $r('app.media.banner_municipal')
    }
    if (key === 'banner_green') {
      return $r('app.media.banner_green')
    }
    if (key === 'project_building' || key === 'p1' || key === 'p2') {
      return $r('app.media.project_building')
    }
    if (key === 'project_municipal' || key === 'p3' || key === 'p4') {
      return $r('app.media.project_municipal')
    }
    if (key === 'project_decoration' || key === 'p5' || key === 'p6') {
      return $r('app.media.project_decoration')
    }
    if (key === 'project_landscape' || key === 'p7' || key === 'p8') {
      return $r('app.media.project_landscape')
    }
    if (key === 'news_company' || key === 'n1' || key === 'n5') {
      return $r('app.media.news_company')
    }
    if (key === 'news_industry' || key === 'n3' || key === 'n7') {
      return $r('app.media.news_industry')
    }
    if (key === 'news_project' || key === 'n2' || key === 'n6') {
      return $r('app.media.news_project')
    }
    if (key === 'news_notice' || key === 'n4' || key === 'n8') {
      return $r('app.media.news_notice')
    }
    if (key === 'cert_qualification' || key === 'c1' || key === 'c2' || key === 'c3' || key === 'c4') {
      return $r('app.media.cert_qualification')
    }
    if (key === 'honor_trophy' || key === 'h1' || key === 'h2' || key === 'h3' || key === 'h4') {
      return $r('app.media.honor_trophy')
    }
    if (key === 'news_cover') {
      return $r('app.media.news_company')
    }
    if (key === 'cert_honor') {
      return $r('app.media.cert_qualification')
    }
    if (key === 'contact_office') {
      return $r('app.media.contact_office')
    }
    return MediaCatalog.heroBg()
  }
}
