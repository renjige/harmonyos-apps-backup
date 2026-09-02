import { Theme } from '../design-system/Theme'
import { AtlasKind } from '../../models/FieldModels'

@Component
export struct AtlasQuickStrip {
  @StorageLink('themeEpoch') themeEpoch: number = 0

  private shortLabel(kind: string): string {
    if (kind === '植物图鉴') {
      return '植物'
    }
    if (kind === '动物图鉴') {
      return '动物'
    }
    if (kind === '昆虫图鉴') {
      return '昆虫'
    }
    if (kind === '矿物图鉴') {
      return '矿物'
    }
    return '日常'
  }

  private openAtlas(kind: string): void {
    AppStorage.setOrCreate('folioListMode', 'all')
    AppStorage.setOrCreate('folioAtlasFilter', kind)
    AppStorage.setOrCreate('switchTabIndex', 1)
  }

  build() {
    Column({ space: Theme.space.s2 }) {
      Text('五门图鉴')
        .fontSize(Theme.type.caption)
        .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
        .width('100%')
      Row({ space: Theme.space.s2 }) {
        ForEach(AtlasKind.all(), (kind: string) => {
          Column({ space: 4 }) {
            Text(this.shortLabel(kind))
              .fontSize(Theme.type.bodyS)
              .fontWeight(FontWeight.Medium)
              .fontColor(Theme.colors().brandPrimary)
          }
          .layoutWeight(1)
          .padding({ top: 10, bottom: 10 })
          .backgroundColor(Theme.colors().brandPrimaryContainer)
          .borderRadius(Theme.radius.md)
          .onClick((): void => { this.openAtlas(kind) })
        }, (kind: string) => kind)
      }
      .width('100%')
    }
    .width('100%')
  }
}
