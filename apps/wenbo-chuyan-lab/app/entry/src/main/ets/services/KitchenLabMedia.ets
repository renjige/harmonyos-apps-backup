/** 平台 coverKey → 本地 media 资源；未知 key 回退通用图 */
export class KitchenLabMedia {
  static cover(coverKey: string): Resource {
    if (coverKey === 'recipe_tomato_egg') {
      return $r('app.media.recipe_tomato_egg')
    }
    if (coverKey === 'recipe_broccoli_garlic') {
      return $r('app.media.recipe_broccoli_garlic')
    }
    if (coverKey === 'recipe_braised_tofu') {
      return $r('app.media.recipe_braised_tofu')
    }
    if (coverKey === 'recipe_stir_fry_greens') {
      return $r('app.media.recipe_stir_fry_greens')
    }
    if (coverKey === 'recipe_mushroom_soup') {
      return $r('app.media.recipe_mushroom_soup')
    }
    if (coverKey === 'recipe_scallion_noodles') {
      return $r('app.media.recipe_scallion_noodles')
    }
    if (coverKey === 'recipe_molecular_egg') {
      return $r('app.media.recipe_molecular_egg')
    }
    if (coverKey === 'recipe_salmon_pan') {
      return $r('app.media.recipe_salmon_pan')
    }
    if (coverKey === 'recipe_mapo_tofu') {
      return $r('app.media.recipe_mapo_tofu')
    }
    if (coverKey === 'recipe_lemon_tea') {
      return $r('app.media.recipe_lemon_tea')
    }
    if (coverKey === 'recipe_tomato_egg_noodles') {
      return $r('app.media.recipe_tomato_egg_noodles')
    }
    if (coverKey === 'recipe_garlic_chicken_wings') {
      return $r('app.media.recipe_garlic_chicken_wings')
    }
    if (coverKey === 'recipe_mushroom_tofu_soup') {
      return $r('app.media.recipe_mushroom_tofu_soup')
    }
    return $r('app.media.recipe_tomato_egg')
  }
}
