/** 省市区三级数据（精简版；交付 App 可按服务区域扩展） */
class RegionNode {
  name: string = ''
  children: RegionNode[] = []

  constructor(name: string, children: RegionNode[]) {
    this.name = name
    this.children = children
  }
}

export class RegionSelection {
  province: string = ''
  city: string = ''
  district: string = ''

  fullText(): string {
    if (this.province.length === 0) {
      return ''
    }
    return `${this.province} ${this.city} ${this.district}`.trim()
  }
}

export class RegionCatalog {
  private static tree(): RegionNode[] {
    const qiqiharDistricts: RegionNode[] = [
      new RegionNode('龙沙区', []),
      new RegionNode('建华区', []),
      new RegionNode('铁锋区', []),
      new RegionNode('昂昂溪区', []),
      new RegionNode('富拉尔基区', []),
      new RegionNode('碾子山区', []),
      new RegionNode('梅里斯达斡尔族区', []),
      new RegionNode('讷河市', []),
      new RegionNode('龙江县', []),
      new RegionNode('依安县', []),
      new RegionNode('泰来县', []),
      new RegionNode('甘南县', []),
      new RegionNode('富裕县', []),
      new RegionNode('克山县', []),
      new RegionNode('克东县', []),
      new RegionNode('拜泉县', [])
    ]
    const harbinDistricts: RegionNode[] = [
      new RegionNode('道里区', []),
      new RegionNode('南岗区', []),
      new RegionNode('道外区', []),
      new RegionNode('香坊区', []),
      new RegionNode('松北区', []),
      new RegionNode('平房区', [])
    ]
    const heilongjiang = new RegionNode('黑龙江省', [
      new RegionNode('齐齐哈尔市', qiqiharDistricts),
      new RegionNode('哈尔滨市', harbinDistricts)
    ])
    const beijing = new RegionNode('北京市', [
      new RegionNode('北京市', [
        new RegionNode('东城区', []),
        new RegionNode('西城区', []),
        new RegionNode('朝阳区', []),
        new RegionNode('海淀区', []),
        new RegionNode('丰台区', [])
      ])
    ])
    const shanghai = new RegionNode('上海市', [
      new RegionNode('上海市', [
        new RegionNode('黄浦区', []),
        new RegionNode('徐汇区', []),
        new RegionNode('浦东新区', []),
        new RegionNode('静安区', [])
      ])
    ])
    const guangdong = new RegionNode('广东省', [
      new RegionNode('广州市', [
        new RegionNode('天河区', []),
        new RegionNode('越秀区', []),
        new RegionNode('海珠区', [])
      ]),
      new RegionNode('深圳市', [
        new RegionNode('南山区', []),
        new RegionNode('福田区', []),
        new RegionNode('宝安区', [])
      ])
    ])
    const zhejiang = new RegionNode('浙江省', [
      new RegionNode('杭州市', [
        new RegionNode('西湖区', []),
        new RegionNode('拱墅区', []),
        new RegionNode('滨江区', [])
      ])
    ])
    return [heilongjiang, beijing, shanghai, guangdong, zhejiang]
  }

  static defaultSelection(): RegionSelection {
    const sel = new RegionSelection()
    sel.province = '黑龙江省'
    sel.city = '齐齐哈尔市'
    sel.district = '铁锋区'
    return sel
  }

  static provinceNames(): string[] {
    const out: string[] = []
    for (const p of RegionCatalog.tree()) {
      out.push(p.name)
    }
    return out
  }

  static cityNames(province: string): string[] {
    const out: string[] = []
    const p = RegionCatalog.findProvince(province)
    if (p === null) {
      return out
    }
    for (const c of p.children) {
      out.push(c.name)
    }
    return out
  }

  static districtNames(province: string, city: string): string[] {
    const out: string[] = []
    const c = RegionCatalog.findCity(province, city)
    if (c === null) {
      return out
    }
    for (const d of c.children) {
      out.push(d.name)
    }
    return out
  }

  static indexOf(list: string[], value: string): number {
    for (let i = 0; i < list.length; i++) {
      if (list[i] === value) {
        return i
      }
    }
    return 0
  }

  private static findProvince(name: string): RegionNode | null {
    for (const p of RegionCatalog.tree()) {
      if (p.name === name) {
        return p
      }
    }
    return null
  }

  private static findCity(province: string, city: string): RegionNode | null {
    const p = RegionCatalog.findProvince(province)
    if (p === null) {
      return null
    }
    for (const c of p.children) {
      if (c.name === city) {
        return c
      }
    }
    return null
  }
}
