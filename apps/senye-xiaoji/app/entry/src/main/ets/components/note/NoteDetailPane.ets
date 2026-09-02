import { Theme } from '../design-system/Theme'
import { AppButton } from '../design-system/AppButton'
import { AppIcon } from '../design-system/AppIcon'
import { NoteItem } from '../../models/NoteModels'
import { MoodCatalog } from '../../services/MoodCatalog'
import { NoteDateUtil } from '../../services/NoteDateUtil'
import { NoteNav } from '../../services/NoteNav'
import { NoteStore } from '../../services/NoteStore'
import { SenyeMedia } from '../../services/SenyeMedia'

@Component
export struct NoteDetailPane {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop noteId: string = ''
  onClose: () => void = () => {}
  @State item: NoteItem = new NoteItem()
  @State toastText: string = ''

  aboutToAppear(): void {
    this.load()
  }

  private load(): void {
    const found: NoteItem | undefined = NoteStore.find(this.noteId)
    if (found !== undefined) {
      this.item = found
    }
  }

  private showToast(msg: string): void {
    this.toastText = msg
    setTimeout(() => { this.toastText = '' }, 2400)
  }

  private async removeNote(): Promise<void> {
    await NoteStore.remove(this.noteId)
    this.showToast('记录已删除')
    setTimeout(() => { this.onClose() }, 600)
  }

  build() {
    Stack() {
      Column() {
        Row({ space: Theme.space.s2 }) {
          Column() {
            AppIcon({ name: 'chevron', iconSize: Theme.icon.md, color: Theme.colors().textSecondary })
          }
          .width(44)
          .height(44)
          .justifyContent(FlexAlign.Center)
          .rotate({ angle: 180 })
          .onClick((): void => { this.onClose() })
          Text('记录详情')
            .fontSize(Theme.type.title3)
            .fontWeight(FontWeight.Medium)
            .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
            .layoutWeight(1)
        }
        .width('100%')
        .padding({ left: Theme.space.pageX - 8, right: Theme.space.pageX, top: Theme.space.s2 })

        Scroll() {
          Column({ space: Theme.space.s4 }) {
            Stack({ alignContent: Alignment.BottomStart }) {
              Image(SenyeMedia.ambient())
                .width('100%')
                .height(160)
                .objectFit(ImageFit.Cover)
                .borderRadius(Theme.radius.xl)
              Column()
                .width('100%')
                .height(80)
                .borderRadius({ bottomLeft: Theme.radius.xl, bottomRight: Theme.radius.xl })
                .linearGradient({
                  angle: 180,
                  colors: [['rgba(26,26,26,0)', 0], ['rgba(26,26,26,0.82)', 1]]
                })
              Row({ space: Theme.space.s2 }) {
                Text(MoodCatalog.emojiOf(this.item.mood))
                  .fontSize(24)
                Column({ space: 2 }) {
                  Text(NoteDateUtil.displayDate(this.item.noteDate))
                    .fontSize(Theme.type.subhead)
                    .fontColor('#F7F5F0')
                  Text(`${MoodCatalog.labelOf(this.item.mood)} · ${this.item.timeLabel}`)
                    .fontSize(Theme.type.caption)
                    .fontColor('#EDEAE3')
                }
                .alignItems(HorizontalAlign.Start)
              }
              .padding({ left: Theme.space.s4, bottom: Theme.space.s4, right: Theme.space.s4 })
            }
            .width('100%')

            Column({ space: Theme.space.s2 }) {
              Text(this.item.body)
                .fontSize(Theme.type.body)
                .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
                .width('100%')
              if (this.item.locationLabel.length > 0) {
                Text(`📍 ${this.item.locationLabel}`)
                  .fontSize(Theme.type.caption)
                  .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
                  .width('100%')
              }
            }
            .width('100%')
            .padding(Theme.space.s4)
            .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
            .borderRadius(Theme.radius.xl)

            if (this.item.tagList().length > 0) {
              Flex({ wrap: FlexWrap.Wrap }) {
                ForEach(this.item.tagList(), (tag: string) => {
                  Text(tag)
                    .fontSize(Theme.type.caption)
                    .fontColor(this.themeEpoch >= 0 ? Theme.colors().brandPrimary : Theme.colors().brandPrimary)
                    .padding({ left: 10, right: 10, top: 6, bottom: 6 })
                    .backgroundColor(Theme.colors().brandPrimaryContainer)
                    .borderRadius(Theme.radius.pill)
                    .margin({ right: 8, bottom: 8 })
                }, (tag: string) => tag)
              }
              .width('100%')
            }

            Row({ space: Theme.space.s3 }) {
              Column() {
                AppButton({
                  label: '编辑',
                  variant: 'secondary',
                  onTap: (): void => {
                    NoteNav.closeDetail()
                    NoteNav.openWrite(this.noteId)
                  }
                })
              }
              .layoutWeight(1)
              Column() {
                AppButton({
                  label: '删除',
                  variant: 'secondary',
                  onTap: (): void => { void this.removeNote() }
                })
              }
              .layoutWeight(1)
            }
            .width('100%')
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
        .zIndex(30)
      }
    }
    .width('100%')
    .height('100%')
  }
}
