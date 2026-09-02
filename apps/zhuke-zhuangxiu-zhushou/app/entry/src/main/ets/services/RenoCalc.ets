export class RenoCalcResult {
  ok: boolean = false
  value: string = ''
  hint: string = ''
}

export class RenoCalc {
  static readonly DISCLAIMER: string = '结果仅供装修计划参考，实际用量请结合现场情况确认。'

  static parseNum(raw: string): number {
    const n = Number.parseFloat(raw.trim())
    if (Number.isNaN(n) || n <= 0 || n > 100000) {
      return -1
    }
    return n
  }

  static area(lengthText: string, widthText: string): RenoCalcResult {
    const out = new RenoCalcResult()
    const length = RenoCalc.parseNum(lengthText)
    const width = RenoCalc.parseNum(widthText)
    if (length < 0 || width < 0) {
      out.hint = '请输入有效的长度和宽度'
      return out
    }
    out.ok = true
    out.value = `${(length * width).toFixed(2)} ㎡`
    out.hint = RenoCalc.DISCLAIMER
    return out
  }

  static wall(widthText: string, heightText: string): RenoCalcResult {
    const out = new RenoCalcResult()
    const width = RenoCalc.parseNum(widthText)
    const height = RenoCalc.parseNum(heightText)
    if (width < 0 || height < 0) {
      out.hint = '请输入有效的墙宽和墙高'
      return out
    }
    out.ok = true
    out.value = `${(width * height).toFixed(2)} ㎡`
    out.hint = `门窗洞口需自行扣除。${RenoCalc.DISCLAIMER}`
    return out
  }

  static tiles(areaText: string, tileL: string, tileW: string, lossText: string): RenoCalcResult {
    const out = new RenoCalcResult()
    const area = RenoCalc.parseNum(areaText)
    const length = RenoCalc.parseNum(tileL)
    const width = RenoCalc.parseNum(tileW)
    const loss = RenoCalc.parseNum(lossText)
    if (area < 0 || length < 0 || width < 0 || loss < 0 || loss > 50) {
      out.hint = '请输入有效的面积、瓷砖尺寸和损耗比例（0–50）'
      return out
    }
    const piece = (length / 100) * (width / 100)
    if (piece <= 0) {
      out.hint = '请输入有效的瓷砖长宽（厘米）'
      return out
    }
    const count = Math.ceil((area / piece) * (1 + loss / 100))
    out.ok = true
    out.value = `预计 ${count} 片`
    out.hint = RenoCalc.DISCLAIMER
    return out
  }

  static paint(areaText: string, coatsText: string, coverText: string): RenoCalcResult {
    const out = new RenoCalcResult()
    const area = RenoCalc.parseNum(areaText)
    const coats = RenoCalc.parseNum(coatsText)
    const cover = RenoCalc.parseNum(coverText)
    if (area < 0 || coats < 0 || cover < 0) {
      out.hint = '请输入有效的墙面面积、遍数和单位覆盖面积'
      return out
    }
    const liters = (area * coats) / cover
    out.ok = true
    out.value = `预计 ${liters.toFixed(1)} 升`
    out.hint = RenoCalc.DISCLAIMER
    return out
  }
}
