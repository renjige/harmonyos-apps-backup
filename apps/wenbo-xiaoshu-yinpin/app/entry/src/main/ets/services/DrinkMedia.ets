/** 栏目封面 → $r('app.media.*')，一 key 一图 */

export class DrinkMedia {
  static resource(key: string): Resource {
    if (key === 'drink_lemon_tea') {
      return $r('app.media.drink_lemon_tea')
    }
    if (key === 'drink_lime_soda') {
      return $r('app.media.drink_lime_soda')
    }
    if (key === 'drink_yangmei') {
      return $r('app.media.drink_yangmei')
    }
    if (key === 'drink_lvdou') {
      return $r('app.media.drink_lvdou')
    }
    if (key === 'drink_passion') {
      return $r('app.media.drink_passion')
    }
    if (key === 'drink_peach_oolong') {
      return $r('app.media.drink_peach_oolong')
    }
    if (key === 'drink_watermelon_mint') {
      return $r('app.media.drink_watermelon_mint')
    }
    if (key === 'drink_lemon_honey') {
      return $r('app.media.drink_lemon_honey')
    }
    if (key === 'drink_grape_tea') {
      return $r('app.media.drink_grape_tea')
    }
    if (key === 'drink_banana_shake') {
      return $r('app.media.drink_banana_shake')
    }
    if (key === 'drink_mango_coco') {
      return $r('app.media.drink_mango_coco')
    }
    if (key === 'drink_strawberry') {
      return $r('app.media.drink_strawberry')
    }
    if (key === 'drink_taro') {
      return $r('app.media.drink_taro')
    }
    if (key === 'drink_wm_slush') {
      return $r('app.media.drink_wm_slush')
    }
    if (key === 'drink_mango_slush') {
      return $r('app.media.drink_mango_slush')
    }
    if (key === 'drink_blueberry_ice') {
      return $r('app.media.drink_blueberry_ice')
    }
    if (key === 'drink_mint_slush') {
      return $r('app.media.drink_mint_slush')
    }
    if (key === 'drink_chrysanthemum') {
      return $r('app.media.drink_chrysanthemum')
    }
    if (key === 'drink_mint_herbal') {
      return $r('app.media.drink_mint_herbal')
    }
    if (key === 'drink_lotus') {
      return $r('app.media.drink_lotus')
    }
    if (key === 'drink_chenpi') {
      return $r('app.media.drink_chenpi')
    }
    if (key === 'tip_hot_water') {
      return $r('app.media.tip_hot_water')
    }
    if (key === 'tip_afternoon') {
      return $r('app.media.tip_afternoon')
    }
    if (key === 'tip_evening') {
      return $r('app.media.tip_evening')
    }
    if (key === 'tip_humid') {
      return $r('app.media.tip_humid')
    }
    if (key === 'tip_dry') {
      return $r('app.media.tip_dry')
    }
    if (key === 'tip_tools') {
      return $r('app.media.tip_tools')
    }
    return $r('app.media.drink_suanmei')
  }
}
