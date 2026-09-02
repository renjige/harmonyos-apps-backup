import { Theme } from '../components/design-system/Theme'
import { AppIcon } from '../components/design-system/AppIcon'
import { AppEmpty } from '../components/design-system/AppEmpty'
import { PaletteListCard } from '../components/palette/PaletteListCard'
import { ColorPalette } from '../models/PaletteModels'
import { PaletteStore } from '../services/PaletteStore'

@Component
export struct PalettesPage {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop @Watch('onReloadTokenChange') reloadToken: number = 0
  onOpenPalette: (palette: ColorPalette) => void = () => {}
  @State palettes: ColorPalette[] = []
  @State filtered: ColorPalette[] = []
  @State searchQuery: string = ''
  @State loading: boolean = true

  aboutToAppear(): void {
    void this.load()
  }

  onReloadTokenChange(): void {
    void this.load()
  }

  private async load(): Promise<void> {
    this.loading = true
    this.palettes = await PaletteStore.loadAll()
    this.applyFilter()
    this.loading = false
  }

  private applyFilter(): void {
    const q = this.searchQuery.trim().toLowerCase()
    const next: ColorPalette[] = []
    for (const p of this.palettes) {
      if (q.length > 0) {
        const hay = `${p.name} ${p.note} ${p.tags.join(' ')}`.toLowerCase()
        if (hay.indexOf(q) < 0) {
          continue
        }
      }
      next.push(p)
    }
    this.filtered = next
  }

  build() {
    Column() {
      Column({ space: Theme.space.s2 }) {
        Text('展格配色卡')
          .fontSize(Theme.type.title2)
          .fontWeight(FontWeight.Bold)
          .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
        Text('本地色板管理 · 点击复制色值')
          .fontSize(Theme.type.bodyS)
          .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
      }
      .width('100%')
      .alignItems(HorizontalAlign.Start)
      .padding({ left: Theme.space.pageX, right: Theme.space.pageX, top: Theme.space.s4, bottom: Theme.space.s3 })

      Row({ space: Theme.space.s2 }) {
        AppIcon({ name: 'search', iconSize: Theme.icon.md, color: Theme.colors().textTertiary })
        TextInput({ text: this.searchQuery, placeholder: '搜索色板名称或标签' })
          .layoutWeight(1)
          .height(44)
          .fontSize(Theme.type.bodyS)
          .backgroundColor(Color.Transparent)
          .onChange((v: string) => {
            this.searchQuery = v
            this.applyFilter()
          })
      }
      .width('100%')
      .height(44)
      .padding({ left: Theme.space.s4, right: Theme.space.s4 })
      .margin({ left: Theme.space.pageX, right: Theme.space.pageX, bottom: Theme.space.s3 })
      .backgroundColor(Theme.colors().surfaceSubtle)
      .borderRadius(Theme.radius.pill)

      if (this.loading) {
        Column() {
          LoadingProgress().width(32).height(32).color(Theme.colors().brandPrimary)
        }
        .layoutWeight(1)
        .justifyContent(FlexAlign.Center)
      } else if (this.filtered.length === 0) {
        AppEmpty({
          title: '暂无匹配色板',
          description: '前往「生成」页创建配色，或在设置中导入 JSON',
          actionLabel: '去生成',
          onAction: (): void => {
            AppStorage.setOrCreate('openGeneratorTab', true)
          }
        })
          .layoutWeight(1)
      } else {
        List({ space: Theme.space.s3 }) {
          ForEach(this.filtered, (p: ColorPalette) => {
            ListItem() {
              PaletteListCard({
                palette: p,
                onTap: (): void => { this.onOpenPalette(p) }
              })
            }
          }, (p: ColorPalette) => p.id)
        }
        .layoutWeight(1)
        .width('100%')
        .padding({ left: Theme.space.pageX, right: Theme.space.pageX })
        .edgeEffect(EdgeEffect.Spring)
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfacePage : Theme.colors().surfacePage)
  }
}
