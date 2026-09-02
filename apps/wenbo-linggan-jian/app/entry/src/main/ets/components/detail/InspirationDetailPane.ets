import { Theme } from '../design-system/Theme'
import { AppButton } from '../design-system/AppButton'
import { AppEmpty } from '../design-system/AppEmpty'
import { DetailShell } from '../detail/DetailShell'
import { NoteItem } from '../../models/SlipModels'
import { SlipStore } from '../../services/SlipStore'
import { SlipNav } from '../../services/SlipNav'
import { SlipDateUtil } from '../../services/SlipDateUtil'
import { SlipMedia } from '../../services/SlipMedia'
import { MoodCatalog } from '../../services/MoodCatalog'
import { ConfirmSheet } from '../slip/ConfirmSheet'

@Component
export struct InspirationDetailPane {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop itemId: string = ''
  @Prop @Watch('onToken') refreshToken: number = 0
  @State item: NoteItem = new NoteItem()
  @State missing: boolean = false
  @State confirmDelete: boolean = false
  @State toastText: string = ''

  aboutToAppear(): void {
    this.reload()
  }

  onToken(): void {
    this.reload()
  }

  private reload(): void {
    const found = SlipStore.find(this.itemId)
    if (found === undefined) {
      this.missing = true
      return
    }
    this.missing = false
    this.item = found
  }

  private async toggleFav(): Promise<void> {
    this.item.favorited = !this.item.favorited
    this.item.updatedAt = Date.now()
    await SlipStore.save(this.item)
    this.toastText = this.item.favorited ? '已收藏这份回忆' : '已取消收藏'
    setTimeout(() => { this.toastText = '' }, 1800)
  }

  private async doDelete(): Promise<void> {
    await SlipStore.remove(this.item.id)
    this.confirmDelete = false
    SlipNav.closeDetail()
  }

  build() {
    Stack() {
      if (this.missing) {
        Column() {
          AppEmpty({ title: '这条灵感不见了', description: '也许已经被轻轻收起。' })
          AppButton({ label: '返回', variant: 'secondary', onTap: (): void => { SlipNav.closeDetail() } })
        }
        .width('100%')
        .height('100%')
        .padding(Theme.space.pageX)
        .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfacePage : Theme.colors().surfacePage)
      } else {
        DetailShell({ title: '灵感', onClose: (): void => { SlipNav.closeDetail() } }) {
          Scroll() {
            Column({ space: Theme.space.s5 }) {
              Stack({ alignContent: Alignment.BottomStart }) {
                Image(SlipMedia.cover(this.item.coverKey.length > 0 ? this.item.coverKey : 'hero_paper_window'))
                  .width('100%')
                  .height(220)
                  .objectFit(ImageFit.Cover)
                Column()
                  .width('100%')
                  .height(120)
                  .linearGradient({
                    angle: 180,
                    colors: [['rgba(24,35,58,0)', 0], ['rgba(24,35,58,0.72)', 1]]
                  })
                Text(this.item.displayTitle())
                  .fontSize(Theme.type.title2)
                  .fontWeight(FontWeight.Medium)
                  .fontColor('#F7F3EA')
                  .padding({ left: Theme.space.s4, right: Theme.space.s4, bottom: Theme.space.s4 })
                  .maxLines(2)
              }
              .width('100%')
              .borderRadius(Theme.radius.lg)
              .clip(true)

              Column({ space: 6 }) {
                Text(`${SlipDateUtil.longDate(this.item.noteDate)}  ${this.item.timeLabel}`)
                  .fontSize(Theme.type.footnote)
                  .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
                  .width('100%')
                if (this.item.mood.length > 0) {
                  Text(`心情 · ${MoodCatalog.labelOf(this.item.mood)}`)
                    .fontSize(Theme.type.footnote)
                    .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
                    .width('100%')
                }
                Row({ space: 8 }) {
                  ForEach(this.item.tagList(), (tag: string) => {
                    Text(`#${tag}`)
                      .fontSize(Theme.type.caption)
                      .fontColor(this.themeEpoch >= 0 ? Theme.colors().brandPrimary : Theme.colors().brandPrimary)
                  }, (tag: string) => tag)
                }
                .width('100%')
              }
              .width('100%')
              .padding(Theme.space.s4)
              .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
              .borderRadius(Theme.radius.lg)

              Column({ space: 8 }) {
                Text('正文')
                  .fontSize(Theme.type.caption)
                  .fontColor(Theme.colors().textTertiary)
                  .width('100%')
                Text(this.item.body.length > 0 ? this.item.body : this.item.title)
                  .fontSize(Theme.type.body)
                  .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
                  .lineHeight(26)
                  .width('100%')
              }
              .width('100%')
              .padding(Theme.space.s4)
              .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
              .borderRadius(Theme.radius.lg)

              AppButton({
                label: '做成灵感卡',
                onTap: (): void => { SlipNav.openCard(this.item.id) }
              })
              AppButton({
                label: this.item.favorited ? '取消收藏' : '收藏这份回忆',
                variant: 'secondary',
                onTap: (): void => { void this.toggleFav() }
              })
              AppButton({
                label: '继续编辑',
                variant: 'ghost',
                onTap: (): void => { SlipNav.openWrite(this.item.id) }
              })
              AppButton({
                label: '删除',
                variant: 'danger',
                onTap: (): void => { this.confirmDelete = true }
              })
            }
            .padding({
              left: Theme.space.pageX,
              right: Theme.space.pageX,
              bottom: Theme.space.s10
            })
            .width('100%')
          }
          .layoutWeight(1)
          .scrollBar(BarState.Off)
        }
      }

      if (this.confirmDelete) {
        ConfirmSheet({
          title: '删除这条灵感？',
          subtitle: '删除后无法从应用里找回。',
          keepLabel: '留下它',
          leaveLabel: '删除',
          onKeep: (): void => { this.confirmDelete = false },
          onLeave: (): void => { void this.doDelete() }
        })
      }

      if (this.toastText.length > 0) {
        Column() {
          Text(this.toastText)
            .fontSize(Theme.type.footnote)
            .fontColor(Theme.colors().brandOnPrimary)
            .padding({ left: 16, right: 16, top: 10, bottom: 10 })
            .backgroundColor(Theme.colors().brandPrimary)
            .borderRadius(Theme.radius.pill)
        }
        .width('100%')
        .padding({ top: Theme.space.s6 })
        .alignItems(HorizontalAlign.Center)
        .zIndex(20)
      }
    }
    .width('100%')
    .height('100%')
  }
}
