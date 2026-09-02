/** 栏目封面 → $r('app.media.*')，一 key 一图 */

export class RoadMedia {
  static resource(key: string): Resource {
    if (key === 'hero_road') {
      return $r('app.media.hero_road')
    }
    if (key === 'route_moganshan') {
      return $r('app.media.route_moganshan')
    }
    if (key === 'route_tunxi') {
      return $r('app.media.route_tunxi')
    }
    if (key === 'route_dishui') {
      return $r('app.media.route_dishui')
    }
    if (key === 'route_jingdezhen') {
      return $r('app.media.route_jingdezhen')
    }
    if (key === 'route_qinghaihu') {
      return $r('app.media.route_qinghaihu')
    }
    if (key === 'route_xian') {
      return $r('app.media.route_xian')
    }
    if (key === 'route_gulangyu') {
      return $r('app.media.route_gulangyu')
    }
    if (key === 'route_changbai') {
      return $r('app.media.route_changbai')
    }
    if (key === 'spot_bamboo') {
      return $r('app.media.spot_bamboo')
    }
    if (key === 'spot_stream') {
      return $r('app.media.spot_stream')
    }
    if (key === 'spot_stars') {
      return $r('app.media.spot_stars')
    }
    if (key === 'spot_oldstreet') {
      return $r('app.media.spot_oldstreet')
    }
    if (key === 'spot_paifang') {
      return $r('app.media.spot_paifang')
    }
    if (key === 'spot_science') {
      return $r('app.media.spot_science')
    }
    if (key === 'spot_wetland') {
      return $r('app.media.spot_wetland')
    }
    if (key === 'spot_kiln') {
      return $r('app.media.spot_kiln')
    }
    if (key === 'spot_wheel') {
      return $r('app.media.spot_wheel')
    }
    if (key === 'spot_daotang') {
      return $r('app.media.spot_daotang')
    }
    if (key === 'spot_birdisland') {
      return $r('app.media.spot_birdisland')
    }
    if (key === 'spot_wall') {
      return $r('app.media.spot_wall')
    }
    if (key === 'wx_moganshan') {
      return $r('app.media.wx_moganshan')
    }
    if (key === 'wx_jiangnan') {
      return $r('app.media.wx_jiangnan')
    }
    if (key === 'wx_coast') {
      return $r('app.media.wx_coast')
    }
    if (key === 'wx_plateau') {
      return $r('app.media.wx_plateau')
    }
    if (key === 'empty_plan') {
      return $r('app.media.empty_plan')
    }
    if (key === 'empty_journal') {
      return $r('app.media.empty_journal')
    }
    return $r('app.media.hero_road')
  }
}
