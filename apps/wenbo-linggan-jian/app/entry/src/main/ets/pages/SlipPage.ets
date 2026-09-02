import { Theme } from '../components/design-system/Theme'
import { AppButton } from '../components/design-system/AppButton'
import { AppEmpty } from '../components/design-system/AppEmpty'
import { NoteItem } from '../models/SlipModels'
import { SlipStore } from '../services/SlipStore'
import { SlipDateUtil } from '../services/SlipDateUtil'
import { SlipMedia } from '../services/SlipMedia'
import { SlipNav } from '../services/SlipNav'

@Component
export struct SlipPage {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop @Watch('onRefreshTokenChange') refreshToken: number = 0
  @State current: NoteItem = new NoteItem()
  @State hasItem: boolean = false
  @State toastText: string = ''

  aboutToAppear(): void {
    this.pick('')
  }

  onRefreshTokenChange(): void {
    this.pick(this.hasItem ? this.current.id : '')
  }

  private pick(exceptId: string): void {
    const found = SlipStore.randomOne(exceptId)
    if (found === undefined) {
      this.hasItem = false
      this.current = new NoteItem()
      return
    }
    this.hasItem = true
    this.current = found
  }

  private async favorite(): Promise<void> {
    if (!this.hasItem) {
      return
    }
    this.current.favorited = true
    this.current.updatedAt = Date.now()
    await SlipStore.save(this.current)
    this.toastText = '已收藏这份回忆'
    setTimeout(() => { this.toastText = '' }, 1800)
  }

  build() {
    Stack() {
      Column({ space: Theme.space.s5 }) {
        Column({ space: 6 }) {
          Text('灵感签')
            .fontSize(Theme.type.title1)
            .fontWeight(FontWeight.Medium)
            .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
            .width('100%')
          Text('再次遇见曾经的自己。')
            .fontSize(Theme.type.subhead)
            .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
            .width('100%')
        }
        .width('100%')
        .padding({ left: Theme.space.pageX, right: Theme.space.pageX, top: Theme.space.pageY })

        if (!this.hasItem) {
          AppEmpty({
            title: '还没有灵感签',
            description: '记录第一份灵感，让未来的你再次遇见它。',
            actionLabel: '记录灵感',
            onAction: (): void => { SlipNav.openWrite('') }
          })
            .layoutWeight(1)
        } else {
          Column() {
            Stack({ alignContent: Alignment.BottomStart }) {
              Image(SlipMedia.cover(this.current.coverKey.length > 0 ? this.current.coverKey : 'cover_folded_jian'))
                .width('100%')
                .height(280)
                .objectFit(ImageFit.Cover)
              Column()
                .width('100%')
                .height(140)
                .linearGradient({
                  angle: 180,
                  colors: [['rgba(24,35,58,0)', 0], ['rgba(24,35,58,0.72)', 1]]
                })
              Column({ space: 10 }) {
                Text(this.current.body.length > 0 ? this.current.body : this.current.displayTitle())
                  .fontSize(Theme.type.title3)
                  .fontWeight(FontWeight.Medium)
                  .fontColor('#F7F3EA')
                  .lineHeight(26)
                  .width('100%')
                  .maxLines(5)
                Text(SlipDateUtil.longDate(this.current.noteDate))
                  .fontSize(Theme.type.footnote)
                  .fontColor('#E5B86B')
                  .width('100%')
              }
              .padding(20)
            }
            .width('100%')
            .borderRadius(Theme.radius.xl)
            .clip(true)
              .onClick((): void => {
                SlipNav.openDetail(this.current.id)
              })

            Column({ space: Theme.space.s3 }) {
              AppButton({
                label: '再遇一条灵感',
                onTap: (): void => {
                  this.pick(this.current.id)
                }
              })
              AppButton({
                label: '收藏这份回忆',
                variant: 'secondary',
                onTap: (): void => { void this.favorite() }
              })
            }
            .width('100%')
            .padding({ top: Theme.space.s4 })
          }
          .layoutWeight(1)
          .padding({ left: Theme.space.pageX, right: Theme.space.pageX })
          .width('100%')
        }
      }
      .width('100%')
      .height('100%')
      .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfacePage : Theme.colors().surfacePage)

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
