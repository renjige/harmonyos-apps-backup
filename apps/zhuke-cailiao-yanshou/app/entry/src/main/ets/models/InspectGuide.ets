export class GuideItem {
  category: string = ''
  summary: string = ''
  point1: string = ''
  point2: string = ''
  point3: string = ''
  extraA: string = ''
  extraB: string = ''
}

export class InspectGuide {
  static of(category: string): GuideItem {
    const item = new GuideItem()
    item.category = category
    if (category === '水泥') {
      item.summary = '核对强度等级、出厂日期与防潮，避免受潮结块进场。'
      item.point1 = '袋装标识清晰，强度等级与设计一致'
      item.point2 = '包装无破损，无受潮结块'
      item.point3 = '出厂合格证、检测报告齐全'
      item.extraA = '受潮结块'
      item.extraB = '出厂合格证'
      return item
    }
    if (category === '钢材') {
      item.summary = '核对规格、标识与锈蚀，保证可追溯。'
      item.point1 = '规格、牌号与送货单一致'
      item.point2 = '表面锈蚀未超过进场允许范围'
      item.point3 = '质保书、炉批号可对应'
      item.extraA = '规格标识'
      item.extraB = '锈蚀情况'
      return item
    }
    if (category === '木材') {
      item.summary = '关注含水、腐朽虫蛀与截面规格。'
      item.point1 = '规格尺寸符合施工要求'
      item.point2 = '无明显腐朽、虫蛀、开裂'
      item.point3 = '干燥程度可接受，无严重变形'
      item.extraA = '腐朽虫蛀'
      item.extraB = '截面规格'
      return item
    }
    if (category === '板材') {
      item.summary = '核对层数、厚度与边角完整。'
      item.point1 = '厚度、幅面与订单一致'
      item.point2 = '无缺角、分层、明显变形'
      item.point3 = '环保或合格证明按项目要求备齐'
      item.extraA = '分层缺角'
      item.extraB = '厚度核对'
      return item
    }
    if (category === '瓷砖') {
      item.summary = '核对规格色号、边角与表面缺陷。'
      item.point1 = '规格、色号与样板一致'
      item.point2 = '无缺棱掉角、裂纹、釉面缺陷'
      item.point3 = '抽检尺寸与平整度可接受'
      item.extraA = '色差'
      item.extraB = '缺棱掉角'
      return item
    }
    if (category === '石材') {
      item.summary = '关注纹理色差、裂缝与厚度。'
      item.point1 = '品种、厚度与设计一致'
      item.point2 = '无贯通裂缝、缺角'
      item.point3 = '防护与合格资料按需备齐'
      item.extraA = '裂缝缺角'
      item.extraB = '厚度色差'
      return item
    }
    if (category === '管材') {
      item.summary = '核对管径壁厚、端口与标识。'
      item.point1 = '规格、材质标识清晰'
      item.point2 = '端口无变形、裂纹'
      item.point3 = '合格证与批次可对应'
      item.extraA = '端口变形'
      item.extraB = '规格标识'
      return item
    }
    if (category === '电线电缆') {
      item.summary = '核对型号截面、绝缘与盘具完整性。'
      item.point1 = '型号、截面与设计一致'
      item.point2 = '绝缘层无破损，盘具完好'
      item.point3 = '3C 或合格证明齐全'
      item.extraA = '绝缘破损'
      item.extraB = '型号截面'
      return item
    }
    if (category === '防水材料') {
      item.summary = '核对型号厚度、卷材外观与储存条件。'
      item.point1 = '型号、厚度符合设计'
      item.point2 = '无粘连、破损、老化裂纹'
      item.point3 = '合格证、检测报告齐全'
      item.extraA = '卷材破损'
      item.extraB = '厚度型号'
      return item
    }
    if (category === '涂料') {
      item.summary = '核对批次色号、包装密封与保质期。'
      item.point1 = '品名、色号与样板一致'
      item.point2 = '桶装密封完好，无涨桶渗漏'
      item.point3 = '在保质期内，合格证齐全'
      item.extraA = '包装密封'
      item.extraB = '保质期'
      return item
    }
    if (category === '门窗') {
      item.summary = '核对型号尺寸、型材与玻璃完好。'
      item.point1 = '型号、洞口尺寸匹配'
      item.point2 = '型材、玻璃无变形破损'
      item.point3 = '五金配件齐全，合格证备齐'
      item.extraA = '尺寸偏差'
      item.extraB = '玻璃破损'
      return item
    }
    if (category === '五金') {
      item.summary = '核对规格数量、防锈与包装。'
      item.point1 = '规格、数量与送货单一致'
      item.point2 = '无严重锈蚀、缺件'
      item.point3 = '包装完整，批次可追溯'
      item.extraA = '锈蚀缺件'
      item.extraB = '数量核对'
      return item
    }
    item.category = '其他'
    item.summary = '按送货单核对名称、数量、外观与资料。'
    item.point1 = '名称规格与单据一致'
    item.point2 = '外观包装无明显异常'
    item.point3 = '随货资料按项目要求收集'
    item.extraA = '外观包装'
    item.extraB = '随货资料'
    return item
  }
}
