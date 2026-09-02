import { KnowledgeArticle } from '../models/JujiaModels'

export class KnowledgeService {
  static articles(): KnowledgeArticle[] {
    const out: KnowledgeArticle[] = []
    const rows: string[][] = [
      ['清洁', '厨房油污清洁', '小苏打 + 热水擦拭灶台，避免钢丝球刮伤台面。', '每周固定一次深度清洁，可配合家务计划提醒执行。'],
      ['收纳', '换季衣物收纳', '按使用频率分区，抽真空袋节省空间并防潮。', '贴标签记录存放位置，便于家人共同查找。'],
      ['家电', '空调滤网维护', '每 1–3 个月清洗滤网，提升制冷效率并减少异味。', '可在物品档案中登记空调并设维护提醒。'],
      ['安全', '家庭用电安全', '插座不过载，离家关闭不必要电源；定期检查老化线缆。', '发现异常登记维修备忘并创建计划跟进。'],
      ['饮食', '冰箱食材管理', '生熟分区，定期清理过期食品，采购前先看库存。', '结合备忘采购清单与物品到期提醒。'],
      ['出行', '证件与行李', '护照、身份证、医保卡集中存放；出行清单勾选防遗漏。', '使用旅行场景包一键生成清单与备忘。'],
      ['育儿', '儿童用品轮换', '玩具与绘本按年龄整理；过期奶粉药品及时清理。', '育儿场景包可快速建立清单与分工备忘。'],
      ['节能', '居家能耗习惯', '峰谷电价时段安排洗衣烘干；长期离家关闭待机电源。', '写入家庭目标，每周回顾完成情况。']
    ]
    for (let i = 0; i < rows.length; i++) {
      const a = new KnowledgeArticle()
      a.id = `kb_${i}`
      a.category = rows[i][0]
      a.title = rows[i][1]
      a.summary = rows[i][2]
      a.body = rows[i][3]
      out.push(a)
    }
    return out
  }
}
