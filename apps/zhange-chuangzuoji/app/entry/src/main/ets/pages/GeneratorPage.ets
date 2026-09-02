import { Theme } from '../components/design-system/Theme'
import { AppButton } from '../components/design-system/AppButton'
import { ColorPalette, HarmonyTypeOption } from '../models/PaletteModels'
import { PaletteHarmonyService } from '../services/PaletteHarmonyService'
import { PaletteStore } from '../services/PaletteStore'

class PresetColor {
  hex: string = ''
  label: string = ''

  static defaults(): PresetColor[] {
    const rows: PresetColor[] = []
    const defs: string[][] = [
      ['#2C3E6B', '深海蓝'],
      ['#C9A84C', '暖金'],
      ['#2D6A4F', '森绿'],
      ['#BE123C', '绯红'],
      ['#6366F1', '靛紫']
    ]
    for (const row of defs) {
      const item = new PresetColor()
      item.hex = row[0]
      item.label = row[1]
      rows.push(item)
    }
    return rows
  }
}

@Component
export struct GeneratorPage {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop reloadToken: number = 0
  onSaved: () => void = () => {}
  @State baseHex: string = '#2C3E6B'
  @State harmonyType: string = 'analogous'
  @State previewColors: string[] = []
  @State paletteName: string = ''
  @State toastText: string = ''
  private presets: PresetColor[] = PresetColor.defaults()
  private harmonyOptions: HarmonyTypeOption[] = HarmonyTypeOption.all()

  aboutToAppear(): void {
    this.regenerate()
  }

  private regenerate(): void {
    this.previewColors = PaletteHarmonyService.generate(this.baseHex, this.harmonyType)
  }

  private showToast(msg: string): void {
    this.toastText = msg
    setTimeout((): void => { this.toastText = '' }, 2400)
  }

  private async savePalette(): Promise<void> {
    const name = this.paletteName.trim()
    if (name.length === 0) {
      this.showToast('请输入色板名称')
      return
    }
    const item = new ColorPalette()
    item.id = `pal_${Date.now()}`
    item.name = name
    item.colors = this.previewColors.slice()
    item.note = `${this.harmonyLabel()} · 主色 ${PaletteHarmonyService.normalizeHex(this.baseHex)}`
    item.createdAt = new Date().toISOString().substring(0, 10)
    item.tags = [this.harmonyLabel()]
    await PaletteStore.save(item)
    this.paletteName = ''
    this.showToast('色板已保存')
    this.onSaved()
  }

  private harmonyLabel(): string {
    for (const opt of this.harmonyOptions) {
      if (opt.id === this.harmonyType) {
        return opt.label
      }
    }
    return '配色'
  }

  build() {
    Stack() {
      Scroll() {
        Column({ space: Theme.space.s4 }) {
          Text('配色生成')
            .fontSize(Theme.type.title2)
            .fontWeight(FontWeight.Bold)
            .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
            .width('100%')
            .margin({ top: Theme.space.s4 })

          Text('选择主色与和谐类型，一键生成并保存色板')
            .fontSize(Theme.type.bodyS)
            .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
            .width('100%')

          Text('主色预设')
            .fontSize(Theme.type.subhead)
            .fontWeight(FontWeight.Medium)
            .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
            .width('100%')

          Row({ space: Theme.space.s2 }) {
            ForEach(this.presets, (item: PresetColor) => {
              Column({ space: 4 }) {
                Column()
                  .width(48)
                  .height(48)
                  .backgroundColor(item.hex)
                  .borderRadius(Theme.radius.sm)
                  .border({
                    width: this.baseHex === item.hex ? 2 : 1,
                    color: this.baseHex === item.hex ? Theme.colors().brandPrimary : Theme.colors().strokeHairline
                  })
                Text(item.label)
                  .fontSize(Theme.type.caption)
                  .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
              }
              .onClick((): void => {
                this.baseHex = item.hex
                this.regenerate()
              })
            }, (item: PresetColor) => item.hex)
          }
          .width('100%')

          Column({ space: Theme.space.s2 }) {
            Text('自定义主色 HEX')
              .fontSize(Theme.type.bodyS)
              .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
            TextInput({ text: this.baseHex, placeholder: '#2C3E6B' })
              .height(44)
              .fontSize(Theme.type.body)
              .onChange((v: string) => {
                this.baseHex = v
                this.regenerate()
              })
          }
          .width('100%')

          Text('和谐类型')
            .fontSize(Theme.type.subhead)
            .fontWeight(FontWeight.Medium)
            .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
            .width('100%')

          Row({ space: Theme.space.s2 }) {
            ForEach(this.harmonyOptions, (opt: HarmonyTypeOption) => {
              Text(opt.label)
                .fontSize(Theme.type.bodyS)
                .fontColor(this.harmonyType === opt.id ? Theme.colors().brandOnPrimary : Theme.colors().textPrimary)
                .padding({ left: 12, right: 12, top: 8, bottom: 8 })
                .backgroundColor(this.harmonyType === opt.id ? Theme.colors().brandPrimary : Theme.colors().surfaceSubtle)
                .borderRadius(Theme.radius.pill)
                .onClick((): void => {
                  this.harmonyType = opt.id
                  this.regenerate()
                })
            }, (opt: HarmonyTypeOption) => opt.id)
          }
          .width('100%')

          Column({ space: Theme.space.s2 }) {
            Text('预览')
              .fontSize(Theme.type.subhead)
              .fontWeight(FontWeight.Medium)
              .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
            Row() {
              ForEach(this.previewColors, (hex: string) => {
                Column()
                  .layoutWeight(1)
                  .height(72)
                  .backgroundColor(hex)
              }, (hex: string) => hex)
            }
            .width('100%')
            .clip(true)
            .borderRadius(Theme.radius.md)
          }
          .width('100%')

          TextInput({ text: this.paletteName, placeholder: '色板名称，如「品牌主色」' })
            .height(44)
            .fontSize(Theme.type.body)
            .onChange((v: string) => { this.paletteName = v })

          AppButton({
            label: '保存到色板库',
            variant: 'primary',
            onTap: (): void => { void this.savePalette() }
          })
        }
        .width('100%')
        .padding(Theme.space.pageX)
        .padding({ bottom: Theme.space.s4 })
      }
      .width('100%')
      .height('100%')
      .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfacePage : Theme.colors().surfacePage)

      if (this.toastText.length > 0) {
        Text(this.toastText)
          .fontSize(Theme.type.bodyS)
          .fontColor(Theme.colors().textOnInverse)
          .padding({ left: 16, right: 16, top: 10, bottom: 10 })
          .backgroundColor(Theme.colors().brandDeep)
          .borderRadius(Theme.radius.pill)
          .position({ x: '8%', y: 48 })
          .zIndex(20)
      }
    }
    .width('100%')
    .height('100%')
  }
}
