export class InsectWikiItem {
  id: string = ''
  name: string = ''
  latin: string = ''
  traits: string = ''
  habit: string = ''
  region: string = ''
  season: string = ''
  coverKey: string = ''
  keywords: string = ''

  static make(id: string, name: string, latin: string, traits: string, habit: string,
    region: string, season: string, coverKey: string, keywords: string): InsectWikiItem {
    const x = new InsectWikiItem()
    x.id = id
    x.name = name
    x.latin = latin
    x.traits = traits
    x.habit = habit
    x.region = region
    x.season = season
    x.coverKey = coverKey
    x.keywords = keywords
    return x
  }
}

export class InsectCatalog {
  static all(): InsectWikiItem[] {
    const list: InsectWikiItem[] = []
    list.push(InsectWikiItem.make('ladybug', '七星瓢虫', 'Coccinella septempunctata',
      '鞘翅朱红，背面常有七个黑斑，体长约 5–8 毫米。',
      '园圃与农田常见，捕食蚜虫，是农田里的小型猎手。',
      '全国广泛分布，公园花坛与菜地最易遇见。',
      '春至秋', 'wiki_ladybug', '瓢虫 甲虫 蚜虫 园圃 七点'))
    list.push(InsectWikiItem.make('honeybee', '中华蜜蜂', 'Apis cerana',
      '体被黄褐绒毛，后足有花粉篮，飞行时嗡鸣清晰。',
      '访花采集花蜜与花粉，是重要传粉者。',
      '山区林缘、果园与庭院花卉附近。',
      '花期为主', 'wiki_honeybee', '蜜蜂 传粉 花朵 蜂蜜'))
    list.push(InsectWikiItem.make('cabbage_white', '菜粉蝶', 'Pieris rapae',
      '翅面白色，前翅顶角有黑斑，飞姿轻盈。',
      '幼虫取食十字花科叶片，成虫喜在菜地巡飞。',
      '菜园、城市绿地与农田。',
      '春、秋高峰', 'wiki_cabbage_white', '粉蝶 蝴蝶 菜青虫 十字花科'))
    list.push(InsectWikiItem.make('dragonfly', '黄衣蜻蜓', 'Pantala flavescens',
      '翅呈琥珀色，腹部细长，停歇时翅平展。',
      '池塘与稻田上空巡飞捕食小型飞虫。',
      '湿地、池塘、稻田与河边。',
      '夏至初秋', 'wiki_dragonfly', '蜻蜓 池塘 巡飞 黄衣'))
    list.push(InsectWikiItem.make('mantis', '中华大刀螳', 'Tenodera sinensis',
      '前足镰刀状，体色多为绿色，善于拟态叶片。',
      '伏击猎手，耐心等候路过的昆虫。',
      '草地、灌丛与农田田埂。',
      '夏秋', 'wiki_mantis', '螳螂 伏击 猎手 草丛'))
    list.push(InsectWikiItem.make('cricket', '斗蟋', 'Velarifictorus micado',
      '体色褐黑，雄虫前翅能互相摩擦发声。',
      '夜间在石缝与草根间鸣叫，杂食。',
      '庭院墙根、荒地与田埂。',
      '夏末至秋', 'wiki_cricket', '蟋蟀 鸣虫 夜间 斗蟋'))
    list.push(InsectWikiItem.make('cicada', '蚱蝉', 'Cryptotympana atrata',
      '体型较大，体色黑亮，复眼突出。',
      '盛夏高鸣，若虫在土中吸食树根汁液多年。',
      '行道树、公园大树与林地。',
      '盛夏', 'wiki_cicada', '蝉 知了 夏天 树干'))
    list.push(InsectWikiItem.make('ant', '日本弓背蚁', 'Camponotus japonicus',
      '体色黑亮，工蚁体长约 8–12 毫米，腹部鼓胀。',
      '地面列队觅食，巢多在土中或朽木。',
      '公园步道、林缘与校园绿地。',
      '全年可见', 'wiki_ant', '蚂蚁 弓背 地面 列队'))
    list.push(InsectWikiItem.make('firefly', '窗萤', 'Pyrocoelia pectoralis',
      '鞘翅偏暗，腹部末端可发光，飞行缓慢。',
      '湿草地与溪边活动，幼虫亦能发光。',
      '潮湿草地、溪流旁与村庄田埂。',
      '初夏夜', 'wiki_firefly', '萤火虫 发光 湿地 夜晚'))
    list.push(InsectWikiItem.make('longhorn', '星天牛', 'Anoplophora chinensis',
      '体黑有白斑，触角极长，常超过体长。',
      '成虫在树干上活动，幼虫蛀食木质部。',
      '果园、行道树与林缘。',
      '夏', 'wiki_longhorn', '天牛 树干 白斑 长触角'))
    list.push(InsectWikiItem.make('locust', '东亚飞蝗', 'Locusta migratoria',
      '后足发达善跳，体色随环境从绿到褐。',
      '草丛中取食禾本科植物，受惊即跳飞。',
      '草原、农田田埂与荒草地。',
      '夏秋', 'wiki_locust', '蝗虫 蚱蜢 跳跃 草地'))
    list.push(InsectWikiItem.make('scarab', '铜绿丽金龟', 'Anomala corpulenta',
      '鞘翅铜绿色有金属光泽，体卵圆形。',
      '夜间趋光，成虫取食叶片，幼虫为蛴螬。',
      '园圃、林地与路灯附近。',
      '夏夜', 'wiki_scarab', '金龟子 铜绿 趋光 蛴螬'))
    return list
  }

  static today(): InsectWikiItem {
    const list = InsectCatalog.all()
    const now = new Date()
    const start = new Date(now.getFullYear(), 0, 0)
    const diff = now.getTime() - start.getTime()
    const day = Math.floor(diff / 86400000)
    const idx = day % list.length
    let n = 0
    for (const item of list) {
      if (n === idx) {
        return item
      }
      n++
    }
    return list.length > 0 ? InsectCatalog.find('ladybug') : InsectWikiItem.make('', '', '', '', '', '', '', 'hero_leaf_dew', '')
  }

  static find(id: string): InsectWikiItem {
    const list = InsectCatalog.all()
    for (const item of list) {
      if (item.id === id) {
        return item
      }
    }
    return InsectCatalog.today()
  }

  static search(q: string): InsectWikiItem[] {
    const key = q.trim()
    const list = InsectCatalog.all()
    if (key.length === 0) {
      return list
    }
    const out: InsectWikiItem[] = []
    for (const item of list) {
      const blob = `${item.name} ${item.latin} ${item.traits} ${item.habit} ${item.keywords}`
      if (blob.indexOf(key) >= 0) {
        out.push(item)
      }
    }
    return out
  }
}
