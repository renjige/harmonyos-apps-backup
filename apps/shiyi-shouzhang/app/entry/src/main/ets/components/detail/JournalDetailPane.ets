import { Theme } from '../design-system/Theme'
import { AppButton } from '../design-system/AppButton'
import { DetailShell } from './DetailShell'
import { JournalEntry, PickupItem } from '../../models/ShiyiModels'
import { MoodCatalog } from '../../services/MoodCatalog'
import { ShiyiMedia } from '../../services/ShiyiMedia'
import { ShiyiNav } from '../../services/ShiyiNav'
import { ShiyiStore } from '../../services/ShiyiStore'

@Component
export struct JournalDetailPane {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop itemId: string = ''
  @Prop @Watch('onOpenChange') openToken: number = 0
  onToast: (text: string) => void = (text: string) => {}
  @State entry: JournalEntry = new JournalEntry()
  @State ready: boolean = false

  aboutToAppear(): void {
    this.load()
  }

  onOpenChange(): void {
    this.load()
  }

  private load(): void {
    const found = ShiyiStore.findJournal(this.itemId)
    if (found !== null) {
      this.entry = found
      this.ready = true
      return
    }
    this.ready = false
  }

  private tagLine(): string {
    if (this.entry.tags.length === 0) {
      return this.entry.keyword.length > 0 ? this.entry.keyword : '未添加标签'
    }
    let line = ''
    for (const tag of this.entry.tags) {
      if (line.length === 0) {
        line = tag
      } else {
        line = `${line}  ·  ${tag}`
      }
    }
    if (this.entry.keyword.length > 0) {
      return `${this.entry.keyword}  ·  ${line}`
    }
    return line
  }

  private async toggleFavorite(): Promise<void> {
    const copy = this.entry
    copy.favorite = !copy.favorite
    copy.updatedAt = Date.now()
    const ok = await ShiyiStore.saveJournal(copy)
    if (!ok) {
      this.onToast('暂时无法保存，请稍后再试。')
      return
    }
    this.entry = copy
    if (copy.favorite) {
      const pickup = new PickupItem()
      pickup.id = ShiyiStore.newId('p')
      pickup.kind = 'happiness'
      pickup.text = copy.oneLiner.length > 0 ? copy.oneLiner : (copy.title.length > 0 ? copy.title : copy.body)
      pickup.sourceId = copy.id
      pickup.createdAt = Date.now()
      await ShiyiStore.savePickup(pickup)
      this.onToast('已收进我的拾意')
      return
    }
    this.onToast('已取消收藏')
  }

  build() {
    DetailShell({
      title: this.ready ? (this.entry.title.length > 0 ? this.entry.title : '手账') : '手账',
      onClose: (): void => {
        ShiyiNav.closeDetail()
      }
    }) {
      if (!this.ready) {
        Column() {
          Text('这一页已经不在了。')
            .fontSize(Theme.type.body)
            .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
            .padding(Theme.space.s6)
        }
        .width('100%')
      } else {
        Scroll() {
          Column({ space: Theme.space.s5 }) {
            Stack({ alignContent: Alignment.BottomStart }) {
              Image(ShiyiMedia.cover(MoodCatalog.coverOf(this.entry.mood)))
                .width('100%')
                .height(200)
                .objectFit(ImageFit.Cover)
                .borderRadius(Theme.radius.xl)
              Column()
                .width('100%')
                .height(200)
                .linearGradient({
                  angle: 180,
                  colors: [['rgba(63,44,54,0.06)', 0], ['rgba(63,44,54,0.72)', 1]]
                })
                .borderRadius(Theme.radius.xl)
              Column({ space: 6 }) {
                Text(ShiyiStore.displayDate(this.entry.entryDate))
                  .fontSize(Theme.type.caption)
                  .fontColor(Theme.colors().textOnInverse)
                Text(this.entry.title.length > 0 ? this.entry.title : '未题名的拾意')
                  .fontSize(Theme.type.title3)
                  .fontWeight(FontWeight.Medium)
                  .fontColor(Theme.colors().textOnInverse)
              }
              .padding(Theme.space.s5)
            }
            .width('100%')

            Text(`${MoodCatalog.markOf(this.entry.mood)}  ${MoodCatalog.labelOf(this.entry.mood)}  ·  ${this.tagLine()}`)
              .fontSize(Theme.type.footnote)
              .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
              .width('100%')

            if (this.entry.oneLiner.length > 0) {
              Column({ space: 8 }) {
                Text('今日一句话')
                  .fontSize(Theme.type.caption)
                  .fontColor(Theme.colors().brandAccent)
                  .width('100%')
                Text(this.entry.oneLiner)
                  .fontSize(Theme.type.subtitleM)
                  .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
                  .width('100%')
              }
              .width('100%')
              .padding(Theme.space.s5)
              .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
              .borderRadius(Theme.radius.card)
            }

            Text(this.entry.body.length > 0 ? this.entry.body : '这一页只有心情，还没有正文。')
              .fontSize(Theme.type.body)
              .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
              .lineHeight(26)
              .width('100%')

            Column({ space: Theme.space.s3 }) {
              AppButton({
                label: this.entry.favorite ? '取消收藏' : '收进我的拾意',
                onTap: (): void => {
                  void this.toggleFavorite()
                }
              })
              AppButton({
                label: '继续写这一页',
                variant: 'secondary',
                onTap: (): void => {
                  ShiyiNav.closeDetail()
                  ShiyiNav.openCompose(this.entry.id, this.entry.entryDate)
                }
              })
            }
            .width('100%')
            .padding({ bottom: Theme.space.s10 })
          }
          .padding({
            left: Theme.space.pageX,
            right: Theme.space.pageX,
            top: Theme.space.s3
          })
        }
        .layoutWeight(1)
        .align(Alignment.Top)
        .scrollBar(BarState.Off)
      }
    }
  }
}
