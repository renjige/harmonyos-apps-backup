import { Theme } from '../components/design-system/Theme'
import { AppButton } from '../components/design-system/AppButton'
import { AppEmpty } from '../components/design-system/AppEmpty'
import { ThoughtCardView } from '../components/box/ThoughtCardView'
import { MapGroup, ThoughtCard } from '../models/ThoughtModels'
import { ThoughtStore } from '../services/ThoughtStore'
import { BoxMedia } from '../services/BoxMedia'
import { DateHelper } from '../services/DateHelper'
import { ThemeMapPane } from '../components/box/ThemeMapPane'
import { pasteboard } from '@kit.BasicServicesKit'

@Component
export struct MindMapPage {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @StorageLink('tbReload') @Watch('onReloadChange') tbReload: number = 0
  @Prop @Watch('onReloadChange') reloadToken: number = 0
  @State groups: MapGroup[] = []
  @State mode: string = 'box'
  @State toastText: string = ''
  onOpenCard: (id: string) => void = (_id: string) => {}

  aboutToAppear(): void {
    void this.reload()
  }

  onReloadChange(): void {
    void this.reload()
  }

  private async reload(): Promise<void> {
    const cards = await ThoughtStore.loadActive()
    this.groups = MindMapPage.buildGroups(cards)
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
    Stack() {
      Column() {
        Row() {
          Text('匣格导图')
            .fontSize(Theme.type.title3)
            .fontWeight(FontWeight.Bold)
            .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
          Blank()
          if (this.mode === 'box') {
            Text('导出')
              .fontSize(Theme.type.footnote)
              .fontColor(Theme.colors().brandPrimary)
              .onClick((): void => { void this.exportTree() })
          }
        }
        .width('100%')
        .padding({ left: Theme.space.pageX, right: Theme.space.pageX, top: Theme.space.s4 })

        Row({ space: Theme.space.s2 }) {
          Text('按标签展开')
            .fontSize(Theme.type.caption)
            .fontColor(this.mode === 'box' ? Theme.colors().brandOnPrimary : Theme.colors().textPrimary)
            .padding({ left: 12, right: 12, top: 8, bottom: 8 })
            .backgroundColor(this.mode === 'box' ? Theme.colors().brandPrimary : Theme.colors().surfaceCard)
            .borderRadius(Theme.radius.pill)
            .onClick((): void => { this.mode = 'box' })
          Text('主题分支')
            .fontSize(Theme.type.caption)
            .fontColor(this.mode === 'theme' ? Theme.colors().brandOnPrimary : Theme.colors().textPrimary)
            .padding({ left: 12, right: 12, top: 8, bottom: 8 })
            .backgroundColor(this.mode === 'theme' ? Theme.colors().brandPrimary : Theme.colors().surfaceCard)
            .borderRadius(Theme.radius.pill)
            .onClick((): void => { this.mode = 'theme' })
        }
        .width('100%')
        .padding({ left: Theme.space.pageX, right: Theme.space.pageX, top: Theme.space.s2 })

        if (this.mode === 'theme') {
          ThemeMapPane().layoutWeight(1)
        } else {
          Scroll() {
            Column({ space: Theme.space.s4 }) {
              Image(BoxMedia.resource('banner_mindmap'))
                .width('100%')
                .height(120)
                .objectFit(ImageFit.Cover)
                .borderRadius(Theme.radius.lg)
              Text('上下滑动查看全部层级。点卡片可进入详情。')
                .fontSize(Theme.type.caption)
                .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
                .width('100%')
              if (this.groups.length === 0) {
                AppEmpty({ title: '还没有可展开的卡片', description: '先在灵感流记下并打上标签' })
              } else {
                ForEach(this.groups, (g: MapGroup) => {
                  Column({ space: Theme.space.s3 }) {
                    Text(`${g.tag} · ${g.cards.length}`)
                      .fontSize(Theme.type.subhead)
                      .fontWeight(FontWeight.Medium)
                      .fontColor(Theme.colors().brandOnPrimary)
                      .padding({ left: 12, right: 12, top: 8, bottom: 8 })
                      .backgroundColor(Theme.colors().brandPrimary)
                      .borderRadius(Theme.radius.md)
                      .width('100%')
                    ForEach(g.cards, (c: ThoughtCard) => {
                      Row({ space: Theme.space.s2 }) {
                        Column()
                          .width(3)
                          .height(56)
                          .backgroundColor(Theme.colors().brandAccent)
                          .borderRadius(2)
                        ThoughtCardView({
                          previewText: c.preview(),
                          tagsLabel: c.tagLine(),
                          shelfLabel: c.shelf,
                          timeLabel: DateHelper.formatShort(c.createdAt),
                          onOpen: (): void => { this.onOpenCard(c.id) }
                        })
                          .layoutWeight(1)
                      }
                      .width('100%')
                    }, (c: ThoughtCard) => `${g.tag}|${c.id}|${c.updatedAt}|${c.tagsCsv}`)
                  }
                  .width('100%')
                  .padding(Theme.space.s3)
                  .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
                  .borderRadius(Theme.radius.lg)
                }, (g: MapGroup) => g.tag)
              }
              AppButton({
                label: '重新按标签展开',
                variant: 'secondary',
                onTap: (): void => { void this.reload() }
              })
            }
            .width('100%')
            .padding({ left: Theme.space.pageX, right: Theme.space.pageX, bottom: Theme.space.s10 })
          }
          .layoutWeight(1)
          .scrollBar(BarState.On)
          .edgeEffect(EdgeEffect.Spring)
        }
      }
      .width('100%')
      .height('100%')
      .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfacePage : Theme.colors().surfacePage)

      if (this.toastText.length > 0) {
        Text(this.toastText)
          .fontSize(Theme.type.footnote)
          .fontColor(Theme.colors().textOnInverse)
          .padding(12)
          .backgroundColor(Theme.colors().brandDeep)
          .borderRadius(Theme.radius.md)
          .margin({ top: 56 })
      }
    }
    .width('100%')
    .height('100%')
  }
}
