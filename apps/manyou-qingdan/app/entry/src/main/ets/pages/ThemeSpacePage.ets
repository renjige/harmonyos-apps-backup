import { Theme } from '../components/design-system/Theme'
import { AppEmpty } from '../components/design-system/AppEmpty'
import { AppIcon } from '../components/design-system/AppIcon'
import { RmTheme } from '../models/RmModels'
import { RmStore } from '../services/RmStore'
import { RmDetailNav } from '../services/RmDetailNav'
import { ThemeAlbumCard } from '../components/rm/ThemeAlbumCard'

class ThemeCount {
  id: string = ''
  n: number = 0
}

@Component
export struct ThemeSpacePage {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @StorageLink('RmDataRev') @Watch('onDataRev') dataRev: number = 0
  @Prop @Watch('onRefresh') refreshToken: number = 0
  @Prop bottomInset: number = 76
  @State themes: RmTheme[] = []
  @State counts: ThemeCount[] = []

  aboutToAppear(): void {
    void this.reload()
  }

  onRefresh(): void {
    void this.reload()
  }

  onDataRev(): void {
    void this.reload()
  }

  private cloneTheme(src: RmTheme): RmTheme {
    const t = new RmTheme()
    t.id = src.id
    t.title = src.title
    t.summary = src.summary
    t.coverKey = src.coverKey
    t.createdAt = src.createdAt
    t.updatedAt = src.updatedAt
    return t
  }

  private async reload(): Promise<void> {
    const raw = await RmStore.loadThemes()
    const next: RmTheme[] = []
    for (const t of raw) {
      next.push(this.cloneTheme(t))
    }
    this.themes = next
    const countRows: ThemeCount[] = []
    for (const t of this.themes) {
      const es = await RmStore.checklistsForTheme(t.id)
      const cs = await RmStore.wishesForTheme(t.id)
      const tc = new ThemeCount()
      tc.id = t.id
      tc.n = es.length + cs.length
      countRows.push(tc)
    }
    this.counts = countRows
  }

  private countOf(id: string): string {
    for (const c of this.counts) {
      if (c.id === id) {
        return `${c.n} 条`
      }
    }
    return '0 条'
  }

  build() {
    Column() {
      Row() {
        Column({ space: 4 }) {
          Text('主题空间')
            .fontSize(Theme.type.title2)
            .fontWeight(FontWeight.Bold)
            .fontColor(Theme.colors().textPrimary)
            .width('100%')
          Text('把片段收进专题收藏册')
            .fontSize(Theme.type.footnote)
            .fontColor(Theme.colors().textSecondary)
            .width('100%')
        }
        .layoutWeight(1)
        AppIcon({ name: 'add', iconSize: Theme.icon.md, color: Theme.colors().brandPrimary })
          .onClick((): void => { RmDetailNav.openThemeEditor('') })
      }
      .width('100%')
      .padding({ left: Theme.space.pageX, right: Theme.space.pageX, top: Theme.space.s3 })

      if (this.themes.length === 0) {
        AppEmpty({
          title: '还没有主题册',
          description: '例如「春日拾光」「我的阅读」「旅行片段」',
          actionLabel: '创建主题',
          onAction: (): void => { RmDetailNav.openThemeEditor('') }
        })
      } else {
        Scroll() {
          Flex({ wrap: FlexWrap.Wrap, justifyContent: FlexAlign.SpaceBetween }) {
            ForEach(this.themes, (t: RmTheme) => {
              Column() {
                ThemeAlbumCard({
                  theme: t,
                  countLabel: this.countOf(t.id),
                  onOpen: (): void => { RmDetailNav.openTheme(t.id) }
                })
              }
              .width('48%')
              .margin({ bottom: Theme.space.s3 })
            }, (t: RmTheme) => `${t.id}_${t.coverKey}_${t.title}_${t.updatedAt}`)
          }
          .padding({
            left: Theme.space.pageX,
            right: Theme.space.pageX,
            top: Theme.space.s4,
            bottom: this.bottomInset + Theme.space.s4
          })
        }
        .layoutWeight(1)
        .width('100%')
        .edgeEffect(EdgeEffect.Spring)
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor(Theme.colors().surfacePage)
  }
}
