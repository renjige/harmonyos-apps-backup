import { Theme } from '../components/design-system/Theme'
import { AppHeader } from '../components/design-system/AppHeader'
import { AppButton } from '../components/design-system/AppButton'
import { AppEmpty } from '../components/design-system/AppEmpty'
import { ThemeSpace } from '../models/XingyuModels'
import { XingyuStore } from '../services/XingyuStore'
import { XingyuNav } from '../services/XingyuNav'
import { DateHelper } from '../services/DateHelper'
import { ThemeCard } from '../components/xingyu/ArchiveCards'

@Component
export struct ThemeSpacePage {
  @StorageLink('xingyuRev') @Watch('onRev') xingyuRev: number = 0
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @State themes: ThemeSpace[] = []
  @State counts: string[] = []

  aboutToAppear(): void {
    void this.reload()
  }

  onRev(): void {
    void this.reload()
  }

  private async reload(): Promise<void> {
    this.themes = await XingyuStore.loadThemes()
    const labels: string[] = []
    for (const t of this.themes) {
      const ns = await XingyuStore.narrativesOfTheme(t.id)
      const sps = await XingyuStore.sparksOfTheme(t.id)
      labels.push(`${t.id}\t${ns.length + sps.length} 条内容`)
    }
    this.counts = labels
  }

  private countOf(id: string): string {
    for (const line of this.counts) {
      if (line.indexOf(`${id}\t`) === 0) {
        return line.substring(id.length + 1)
      }
    }
    return '0 条内容'
  }

  private async adoptPreset(title: string, cover: string): Promise<void> {
    const t = ThemeSpace.createNew(title, cover)
    await XingyuStore.saveTheme(t)
  }

  build() {
    Column() {
      AppHeader({ title: '主题', subtitle: '把兴趣收进星域' })
      Scroll() {
        Column({ space: Theme.space.s4 }) {
          AppButton({
            label: '创建主题空间',
            onTap: () => XingyuNav.openEditor('theme', '')
          })
          if (this.themes.length === 0) {
            AppEmpty({
              title: '还没有主题',
              description: '阅读、旅行、成长……先建一个空的星域。',
              actionLabel: '创建阅读角',
              onAction: () => {
                void this.adoptPreset('我的阅读角', 'cover_reading')
              }
            })
            Row({ space: Theme.space.s2 }) {
              Text('旅行星图')
                .fontSize(Theme.type.caption)
                .fontColor(Theme.colors().textPrimary)
                .padding(Theme.space.s3)
                .backgroundColor(Theme.colors().surfaceCard)
                .borderRadius(Theme.radius.pill)
                .onClick(() => {
                  void this.adoptPreset('旅行星图', 'cover_travel')
                })
              Text('成长记录')
                .fontSize(Theme.type.caption)
                .fontColor(Theme.colors().textPrimary)
                .padding(Theme.space.s3)
                .backgroundColor(Theme.colors().surfaceCard)
                .borderRadius(Theme.radius.pill)
                .onClick(() => {
                  void this.adoptPreset('成长记录', 'cover_growth')
                })
            }
            .width('100%')
          }
          ForEach(this.themes, (t: ThemeSpace) => {
            ThemeCard({
              title: t.title,
              coverKey: t.coverKey,
              countLabel: this.countOf(t.id),
              updatedLabel: `更新于 ${DateHelper.displayDate(DateHelper.keyFromDate(new Date(t.updatedAt)))}`,
              onOpen: () => XingyuNav.openTheme(t.id)
            })
          }, (t: ThemeSpace) => t.id)
        }
        .padding({ left: Theme.space.pageX, right: Theme.space.pageX, bottom: Theme.space.s10 })
        .width('100%')
      }
      .layoutWeight(1)
      .width('100%')
      .scrollBar(BarState.Off)
      .align(Alignment.Top)
    }
    .width('100%')
    .height('100%')
    .backgroundColor(Theme.colors().surfacePage)
  }
}
