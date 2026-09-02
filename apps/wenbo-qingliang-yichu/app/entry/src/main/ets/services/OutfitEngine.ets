import { WardrobeItemModel, WardrobeOutfitModel } from '../models/WardrobeModels'
import { WardrobeLocalStore } from './WardrobeLocalStore'

export class OutfitEngine {
  /**
   * 智慧穿搭生成引擎：根据天气、场景与风格，从衣橱单品中组合最适搭配
   */
  static generateOutfit(weather: string = '晴', scene: string = '日常', style: string = '清爽'): WardrobeOutfitModel {
    const allItems = WardrobeLocalStore.getItems('全部')

    const tops = allItems.filter((x) => x.category === '上装')
    const bottoms = allItems.filter((x) => x.category === '下装')
    const dresses = allItems.filter((x) => x.category === '连衣裙')
    const shoes = allItems.filter((x) => x.category === '鞋履')
    const accessories = allItems.filter((x) => x.category === '配饰' || x.category === '外套')

    // Decide between Dress vs Top+Bottom based on style or availability
    const preferDress = (style === '优雅' || style === '约会' || scene === '约会') && dresses.length > 0 && Math.random() > 0.4

    let title = ''
    let topName = ''
    let bottomName = ''
    let dressName = ''
    let shoesName = ''
    let accessoryName = ''

    if (preferDress && dresses.length > 0) {
      const pickedDress = dresses[Math.floor(Math.random() * dresses.length)]
      dressName = pickedDress.name
      title = `${style}${scene}灵动裙装搭配`
    } else {
      if (tops.length > 0) {
        const matchingTops = tops.filter((x) => x.scene === scene || x.season.includes('夏') || x.season === '四季')
        const pickedTop = matchingTops.length > 0 ? matchingTops[Math.floor(Math.random() * matchingTops.length)] : tops[Math.floor(Math.random() * tops.length)]
        topName = pickedTop.name
      } else {
        topName = '浅蓝亚麻衬衫'
      }

      if (bottoms.length > 0) {
        const matchingBottoms = bottoms.filter((x) => x.scene === scene || x.season.includes('夏') || x.season === '四季')
        const pickedBottom = matchingBottoms.length > 0 ? matchingBottoms[Math.floor(Math.random() * matchingBottoms.length)] : bottoms[Math.floor(Math.random() * bottoms.length)]
        bottomName = pickedBottom.name
      } else {
        bottomName = '米白直筒休闲阔腿裤'
      }

      title = `${style}${scene}清爽干练搭配`
    }

    if (shoes.length > 0) {
      const pickedShoes = shoes[Math.floor(Math.random() * shoes.length)]
      shoesName = pickedShoes.name
    } else {
      shoesName = '经典小白休闲平底鞋'
    }

    if (accessories.length > 0) {
      const pickedAcc = accessories[Math.floor(Math.random() * accessories.length)]
      accessoryName = pickedAcc.name
    } else {
      accessoryName = weather === '晴' ? '防晒轻薄开衫' : '编织草编手提包'
    }

    const tips = OutfitEngine.generateTips(weather, scene, style)

    const outfitId = 'outfit_gen_' + Date.now().toString(36)
    return new WardrobeOutfitModel(
      outfitId,
      title,
      style,
      scene,
      weather,
      topName,
      bottomName,
      shoesName,
      accessoryName,
      dressName,
      tips,
      false
    )
  }

  static generateTips(weather: string, scene: string, style: string): string {
    let weatherTip = ''
    if (weather === '晴') {
      weatherTip = '今天晴好阳光充足，推荐浅色透气面料，搭配轻薄防晒与舒适平底鞋。'
    } else if (weather === '多云' || weather === '阴') {
      weatherTip = '多云微风体感适宜，米白与薄荷绿中性色彩搭配，营造自然松弛的层次感。'
    } else {
      weatherTip = '雨天湿度稍大，建议利落短款或垂坠抗皱面料，保持整洁干爽。'
    }

    let sceneTip = ''
    if (scene === '通勤') {
      sceneTip = '职场微正式感：浅色系衬衫与质感西裤相得益彰，专业又不失夏日轻盈。'
    } else if (scene === '约会') {
      sceneTip = '优雅灵动氛围：柔和色调点缀精致配饰，视觉上给人温润随和的印象。'
    } else if (scene === '运动') {
      sceneTip = '活力舒适首选：弹性透气剪裁，随时随地享受自由舒展。'
    } else {
      sceneTip = '日常随性搭配：基础款单品相互呼应，极简大方，轻松展现个人品味。'
    }

    return `${weatherTip} ${sceneTip}`
  }
}
