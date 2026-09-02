export class ColorPalette {
  id: string = ''
  name: string = ''
  colors: string[] = []
  note: string = ''
  createdAt: string = ''
  tags: string[] = []
}

export class PaletteStats {
  totalPalettes: number = 0
  totalColors: number = 0
  lastUpdated: string = '暂无'
  visitCount: number = 0
}

export class PaletteExportBundle {
  version: string = '1'
  palettes: ColorPalette[] = []
}

export class HarmonyTypeOption {
  id: string = ''
  label: string = ''

  static all(): HarmonyTypeOption[] {
    const rows: HarmonyTypeOption[] = []
    const defs: string[][] = [
      ['analogous', '邻近色'],
      ['complementary', '互补色'],
      ['triadic', '三角色'],
      ['split', '分裂互补']
    ]
    for (const row of defs) {
      const item = new HarmonyTypeOption()
      item.id = row[0]
      item.label = row[1]
      rows.push(item)
    }
    return rows
  }
}
