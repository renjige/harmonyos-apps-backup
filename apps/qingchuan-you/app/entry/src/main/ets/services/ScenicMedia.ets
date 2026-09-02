/** 栏目封面 → $r('app.media.*')，一 key 一图 */

export class ScenicMedia {
  static resource(key: string): Resource {
    if (key === 'hero_bg') {
      return $r('app.media.hero_bg')
    }
    if (key === 'banner_01') {
      return $r('app.media.banner_01')
    }
    if (key === 'banner_02') {
      return $r('app.media.banner_02')
    }
    if (key === 'dest_westlake') {
      return $r('app.media.dest_westlake')
    }
    if (key === 'dest_zhangjiajie') {
      return $r('app.media.dest_zhangjiajie')
    }
    if (key === 'dest_chengdu') {
      return $r('app.media.dest_chengdu')
    }
    if (key === 'dest_dunhuang') {
      return $r('app.media.dest_dunhuang')
    }
    if (key === 'dest_huangshan') {
      return $r('app.media.dest_huangshan')
    }
    if (key === 'dest_xian') {
      return $r('app.media.dest_xian')
    }
    if (key === 'dest_dali') {
      return $r('app.media.dest_dali')
    }
    if (key === 'dest_qingdao') {
      return $r('app.media.dest_qingdao')
    }
    if (key === 'insp_lake') {
      return $r('app.media.insp_lake')
    }
    if (key === 'insp_peaks') {
      return $r('app.media.insp_peaks')
    }
    if (key === 'insp_chengdu') {
      return $r('app.media.insp_chengdu')
    }
    if (key === 'insp_desert') {
      return $r('app.media.insp_desert')
    }
    if (key === 'insp_wall') {
      return $r('app.media.insp_wall')
    }
    if (key === 'insp_sea') {
      return $r('app.media.insp_sea')
    }
    if (key === 'note_westlake') {
      return $r('app.media.note_westlake')
    }
    if (key === 'note_valley') {
      return $r('app.media.note_valley')
    }
    if (key === 'note_tea') {
      return $r('app.media.note_tea')
    }
    if (key === 'note_spring') {
      return $r('app.media.note_spring')
    }
    if (key === 'note_xian') {
      return $r('app.media.note_xian')
    }
    if (key === 'note_qingdao') {
      return $r('app.media.note_qingdao')
    }
    return $r('app.media.hero_bg')
  }
}
