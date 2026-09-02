import { Theme } from '../components/design-system/Theme'
import { AppButton } from '../components/design-system/AppButton'
import { AppEmpty } from '../components/design-system/AppEmpty'
import { ThoughtCardView } from '../components/box/ThoughtCardView'
import { MapGroup, ThoughtCard } from '../models/ThoughtModels'
import { ThoughtStore } from '../services/ThoughtStore'
import { DateHelper } from '../services/DateHelper'
import { ThemeMapPane } from '../components/box/ThemeMapPane'
import { pasteboard } from '@kit.BasicServicesKit'

@Component
export struct MindMapPage {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @StorageLink('tbReload') @Watch('onReloadChange') tbReload: number = 0
  @Prop @Watch('onReloadChange') reloadToken: number = 0
  @Prop @Watch('onTabVisibleChange') tabVisible: boolean = false
  @State groups: MapGroup[] = []
  @State mode: string = 'box'
  @State mapEpoch: number = 0
  @State totalCards: number = 0
  @State toastText: string = ''
  onOpenCard: (id: string) => void = (_id: string) => {}

  aboutToAppear(): void {
    void this.performReload(false)
  }

  onReloadChange(): void {
    void this.performReload(false)
  }

  onTabVisibleChange(): void {
    if (this.tabVisible) {
      void this.performReload(false)
    }
  }

  private async performReload(showFeedback: boolean): Promise<void> {
    const cards = await ThoughtStore.loadActive()
    this.groups = MindMapPage.buildGroups(cards)
    this.totalCards = cards.length
    this.mapEpoch = this.mapEpoch + 1
    if (showFeedback) {
      this.showToast(`已展开 ${cards.length} 张卡片 · ${this.groups.length} 个标签组`)
    }
  }

  private refreshTagMap(): void {
    void this.performReload(true)
  }

  private switchToBoxMode(): void {
    this.mode = 'box'
    void this.performReload(false)
  }

  private static buildGroups(cards: ThoughtCard[]): MapGroup[] {
    const order: string[] = []
    const groups: MapGroup[] = []
    for (const c of cards) {
      const t = c.primaryTag()
      let idx = -1
      for (let i = 0; i < order.length; i++) {
        if (order[i] === t) {
          idx = i
          break
        }
      }
      if (idx < 0) {
        const g = new MapGroup()
        g.tag = t
        g.cards.push(c)
        groups.push(g)
        order.push(t)
      } else {
        groups[idx].cards.push(c)
      }
    }
    return groups
  }

  private showToast(msg: string): void {
    this.toastText = msg
    setTimeout((): void => { this.toastText = '' }, 2400)
  }

  private async exportTree(): Promise<void> {
    const lines: string[] = []
    lines.push('# 思维匣导图')
    for (const g of this.groups) {
      lines.push(`- ${g.tag}`)
      for (const c of g.cards) {
        lines.push(`  - ${c.titleLine()}`)
      }
    }
    try {
      const data = pasteboard.createData(pasteboard.MIMETYPE_TEXT_PLAIN, lines.join('\n'))
      const board = pasteboard.getSystemPasteboard()
      await board.setData(data)
      this.showToast('导图结构已复制')
    } catch {
      this.showToast('复制失败')
    }
  }

  build() {
    Stack({ alignContent: Alignment.Top }) {
      Column() {
        if (this.mode === 'theme') {
          Column() {
            this.MapToolbar()
            ThemeMapPane({ reloadToken: this.reloadToken + this.tbReload + this.mapEpoch }).layoutWeight(1)
          }
          .width('100%')
          .height('100%')
        } else {
          Scroll() {
            Column({ space: Theme.space.section }) {
              Stack({ alignContent: Alignment.BottomStart }) {
                Image($r('app.media.banner_mindmap'))
                  .width('100%')
                  .height(200)
                  .objectFit(ImageFit.Cover)
                Column()
                  .width('100%')
                  .height(200)
                  .linearGradient({
                    angle: 180,
                    colors: [
                      ['rgba(15,23,42,0.06)', 0.0],
                      ['rgba(15,23,42,0.42)', 0.45],
                      ['rgba(26,35,50,0.90)', 1.0]
                    ]
                  })
                Column({ space: 6 }) {
                  Text('匣格导图')
                    .fontSize(Theme.type.titleL)
                    .fontWeight(FontWeight.Bold)
                    .fontColor(Theme.colors().textOnInverse)
                  Text(`${this.totalCards} 张卡片 · ${this.groups.length} 个标签屉`)
                    .fontSize(Theme.type.caption)
                    .fontColor(Theme.colors().textOnInverse)
                }
                .padding({ left: Theme.space.pageX, right: Theme.space.pageX, bottom: Theme.space.s6 })
              }
              .width('100%')
              .height(200)

              this.MapToolbar()

              Column({ space: Theme.space.s3 }) {
                if (this.groups.length === 0) {
                  AppEmpty({ title: '还没有可展开的卡片', description: '先在灵感流记下并打上标签' })
                } else {
                  ForEach(this.groups, (g: MapGroup) => {
                    Column({ space: Theme.space.s3 }) {
                      Row({ space: Theme.space.s3 }) {
                        Column()
                          .width(4)
                          .height(36)
                          .backgroundColor(Theme.colors().brandAccent)
                          .borderRadius(Theme.radius.pill)
                        Column({ space: 2 }) {
                          Text(g.tag)
                            .fontSize(Theme.type.titleS)
                            .fontWeight(FontWeight.Medium)
                            .fontColor(Theme.colors().textPrimary)
                          Text(`${g.cards.length} 张`)
                            .fontSize(Theme.type.caption)
                            .fontColor(Theme.colors().textSecondary)
                        }
                        .alignItems(HorizontalAlign.Start)
                        .layoutWeight(1)
                      }
                      .width('100%')
                      ForEach(g.cards, (c: ThoughtCard) => {
                        ThoughtCardView({
                          previewText: c.preview(),
                          tagsLabel: c.tagLine(),
                          shelfLabel: c.shelf,
                          timeLabel: DateHelper.formatShort(c.createdAt),
                          imagePath: c.imagePath,
                          onOpen: (): void => { this.onOpenCard(c.id) }
                        })
                      }, (c: ThoughtCard) => `${this.mapEpoch}|${g.tag}|${c.id}|${c.updatedAt}|${c.tagsCsv}|${c.imagePath}`)
                    }
                    .width('100%')
                    .padding(Theme.space.s5)
                    .backgroundColor(Theme.colors().surfaceCard)
                    .borderRadius(Theme.radius.xl)
                    .border({ width: 1, color: Theme.colors().strokeHairline })
                  }, (g: MapGroup) => `${this.mapEpoch}|${g.tag}|${g.cards.length}`)
                }
                Row() {
                  AppButton({
                    label: '重新按标签展开',
                    variant: 'secondary',
                    onTap: (): void => { this.refreshTagMap() }
                  })
                }
                .width('100%')
                .onClick((): void => { this.refreshTagMap() })
              }
              .padding({ left: Theme.space.pageX, right: Theme.space.pageX })
            }
            .width('100%')
            .padding({ bottom: 88 })
          }
          .layoutWeight(1)
          .scrollBar(BarState.Off)
          .edgeEffect(EdgeEffect.Spring)
          .onVisibleAreaChange([0.0, 1.0], (isVisible: boolean, currentRatio: number): void => {
            if (isVisible && currentRatio > 0 && this.tabVisible) {
              void this.performReload(false)
            }
          })
        }
      }
      .width('100%')
      .height('100%')
      .backgroundColor(Theme.colors().surfacePage)

      if (this.toastText.length > 0) {
        Text(this.toastText)
          .fontSize(Theme.type.footnote)
          .fontColor(Theme.colors().textOnInverse)
          .padding({ left: 16, right: 16, top: 10, bottom: 10 })
          .backgroundColor(Theme.colors().brandDeep)
          .borderRadius(Theme.radius.pill)
          .margin({ top: Theme.space.s6 })
          .zIndex(20)
      }
    }
    .width('100%')
    .height('100%')
  }

  @Builder
  MapToolbar() {
    Row({ space: Theme.space.s2 }) {
      Text('按标签展开')
        .fontSize(Theme.type.caption)
        .fontColor(this.mode === 'box' ? Theme.colors().brandOnPrimary : Theme.colors().labelOnContainer)
        .padding({ left: 12, right: 12, top: 8, bottom: 8 })
        .backgroundColor(this.mode === 'box' ? Theme.colors().brandPrimary : Theme.colors().surfaceCard)
        .borderRadius(Theme.radius.sm)
        .border({ width: 1, color: this.mode === 'box' ? Theme.colors().brandPrimary : Theme.colors().strokeStrong })
        .onClick((): void => { this.switchToBoxMode() })
      Text('主题分支')
        .fontSize(Theme.type.caption)
        .fontColor(this.mode === 'theme' ? Theme.colors().brandOnPrimary : Theme.colors().labelOnContainer)
        .padding({ left: 12, right: 12, top: 8, bottom: 8 })
        .backgroundColor(this.mode === 'theme' ? Theme.colors().brandPrimary : Theme.colors().surfaceCard)
        .borderRadius(Theme.radius.sm)
        .border({ width: 1, color: this.mode === 'theme' ? Theme.colors().brandPrimary : Theme.colors().strokeStrong })
        .onClick((): void => { this.mode = 'theme' })
      Blank()
      if (this.mode === 'box') {
        Text('导出')
          .fontSize(Theme.type.caption)
          .fontColor(Theme.colors().brandPrimary)
          .onClick((): void => { void this.exportTree() })
      }
    }
    .width('100%')
    .padding({ left: Theme.space.pageX, right: Theme.space.pageX })
  }
}
