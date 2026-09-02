/**
 * 一格一图：每个 coverKey 对应唯一 media 资源，禁止共图合并映射。
 */
export class GewuMedia {
  static coverResource(coverKey: string): Resource {
    if (coverKey === 'obj_compass') {
      return $r('app.media.obj_compass')
    }
    if (coverKey === 'obj_print') {
      return $r('app.media.obj_print')
    }
    if (coverKey === 'obj_paper') {
      return $r('app.media.obj_paper')
    }
    if (coverKey === 'obj_bronze') {
      return $r('app.media.obj_bronze')
    }
    if (coverKey === 'obj_abacus') {
      return $r('app.media.obj_abacus')
    }
    if (coverKey === 'obj_garden') {
      return $r('app.media.obj_garden')
    }
    if (coverKey === 'obj_star') {
      return $r('app.media.obj_star')
    }
    if (coverKey === 'obj_lacquer') {
      return $r('app.media.obj_lacquer')
    }
    if (coverKey === 'obj_terracotta') {
      return $r('app.media.obj_terracotta')
    }
    if (coverKey === 'obj_ink') {
      return $r('app.media.obj_ink')
    }
    if (coverKey === 'obj_seismograph') {
      return $r('app.media.obj_seismograph')
    }
    if (coverKey === 'obj_silk') {
      return $r('app.media.obj_silk')
    }
    if (coverKey === 'obj_porcelain') {
      return $r('app.media.obj_porcelain')
    }
    if (coverKey === 'obj_telescope') {
      return $r('app.media.obj_telescope')
    }
    if (coverKey === 'obj_bamboo') {
      return $r('app.media.obj_bamboo')
    }
    if (coverKey === 'obj_map') {
      return $r('app.media.obj_map')
    }
    if (coverKey === 'obj_tea') {
      return $r('app.media.obj_tea')
    }
    if (coverKey === 'obj_jade') {
      return $r('app.media.obj_jade')
    }
    if (coverKey === 'obj_bell') {
      return $r('app.media.obj_bell')
    }
    if (coverKey === 'obj_fan') {
      return $r('app.media.obj_fan')
    }
    if (coverKey === 'obj_puppet') {
      return $r('app.media.obj_puppet')
    }
    if (coverKey === 'obj_waterclock') {
      return $r('app.media.obj_waterclock')
    }
    if (coverKey === 'hero_gewu') {
      return $r('app.media.hero_gewu')
    }
    if (coverKey === 'banner_lattice') {
      return $r('app.media.banner_lattice')
    }
    if (coverKey === 'banner_scroll') {
      return $r('app.media.banner_scroll')
    }
    if (coverKey === 'atlas_lotus') {
      return $r('app.media.atlas_lotus')
    }
    if (coverKey === 'atlas_pine') {
      return $r('app.media.atlas_pine')
    }
    if (coverKey === 'atlas_sparrow') {
      return $r('app.media.atlas_sparrow')
    }
    if (coverKey === 'atlas_koi') {
      return $r('app.media.atlas_koi')
    }
    if (coverKey === 'atlas_cicada') {
      return $r('app.media.atlas_cicada')
    }
    if (coverKey === 'atlas_firefly') {
      return $r('app.media.atlas_firefly')
    }
    if (coverKey === 'atlas_quartz') {
      return $r('app.media.atlas_quartz')
    }
    if (coverKey === 'atlas_amber') {
      return $r('app.media.atlas_amber')
    }
    if (coverKey === 'atlas_teapot') {
      return $r('app.media.atlas_teapot')
    }
    if (coverKey === 'atlas_lantern') {
      return $r('app.media.atlas_lantern')
    }
    return $r('app.media.hero_gewu')
  }
}
