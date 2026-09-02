import { Theme } from '../design-system/Theme'
import { AppCard } from '../design-system/AppCard'
import { AppButton } from '../design-system/AppButton'
import { AppEmpty } from '../design-system/AppEmpty'
import { DetailShell } from './DetailShell'
import { NoteItem } from '../../models/NoteModels'
import { HeartNoteStore } from '../../services/HeartNoteStore'
import { HeartNoteMedia } from '../../services/HeartNoteMedia'
import { MoodCatalog } from '../../services/MoodCatalog'
import { NoteDateUtil } from '../../services/NoteDateUtil'
import { NoteNav } from '../../services/NoteNav'

@Component
export struct NoteDetailPane {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop itemId: string = ''
  @Prop @Watch('onItemIdChange') refreshToken: number = 0
  onDeleted: () => void = () => {}
  @State item: NoteItem | undefined = undefined
  @State confirmDelete: boolean = false
  @State toastText: string = ''

  aboutToAppear(): void {
    this.loadItem()
  }

  onItemIdChange(): void {
    this.confirmDelete = false
    this.loadItem()
  }

  private loadItem(): void {
    this.item = HeartNoteStore.find(this.itemId)
  }

  private showToast(msg: string): void {
    this.toastText = msg
    setTimeout(() => { this.toastText = '' }, 2200)
  }

  private async doDelete(): Promise<void> {
    if (this.item === undefined) {
      return
    }
    await HeartNoteStore.remove(this.item.id)
    this.confirmDelete = false
    NoteNav.closeDetail()
    this.onDeleted()
  }

  build() {
    Stack() {
      if (this.item === undefined) {
        Column() {
          AppEmpty({ title: '这篇心笺不在了', description: '也许它已经被轻轻放走。' })
          AppButton({ label: '返回', variant: 'secondary', onTap: (): void => { NoteNav.closeDetail() } })
        }
        .width('100%')
        .height('100%')
        .padding(Theme.space.pageX)
        .justifyContent(FlexAlign.Center)
      } else {
        DetailShell({ title: this.item.title, onClose: (): void => { NoteNav.closeDetail() } }) {
          Scroll() {
            Column({ space: Theme.space.s4 }) {
              Stack() {
                Image(this.item.photoUri0.length > 0 ? this.item.photoUri0 : HeartNoteMedia.cover(this.item.coverKey))
                  .width('100%')
                  .height(220)
                  .objectFit(ImageFit.Cover)
                Column() {
                  Text(this.item.title)
                    .fontSize(Theme.type.title1)
                    .fontWeight(FontWeight.Medium)
                    .fontColor('#FFFFFF')
                    .width('100%')
                }
                .width('100%')
                .padding({ left: 20, right: 20, bottom: 18 })
                .linearGradient({
                  angle: 180,
                  colors: [['rgba(39,35,33,0)', 0], ['rgba(39,35,33,0.72)', 1]]
                })
                .alignItems(HorizontalAlign.Start)
              }
              .width('100%')
              .borderRadius(Theme.radius.lg)
              .clip(true)

              AppCard({ title: '这一天' }) {
                Text(`${NoteDateUtil.cardDate(this.item.noteDate)} · ${this.item.period} · ${MoodCatalog.labelOf(this.item.mood)}`)
                  .fontSize(Theme.type.subhead)
                  .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
                  .width('100%')
              }

              AppCard({ title: '想留下的话' }) {
                Text(this.item.body.length > 0 ? this.item.body : '这一页只有标题。')
                  .fontSize(Theme.type.body)
                  .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
                  .width('100%')
              }

              if (this.item.tagList().length > 0) {
                Row({ space: 8 }) {
                  ForEach(this.item.tagList(), (tag: string) => {
                    Text(`#${tag}`)
                      .fontSize(Theme.type.caption)
                      .fontColor(this.themeEpoch >= 0 ? Theme.colors().brandPrimary : Theme.colors().brandPrimary)
                      .padding({ left: 10, right: 10, top: 4, bottom: 4 })
                      .backgroundColor(Theme.colors().brandPrimaryContainer)
                      .borderRadius(Theme.radius.pill)
                  }, (tag: string) => tag)
                }
                .width('100%')
              }

              AppButton({
                label: '继续写这一封',
                onTap: (): void => {
                  if (this.item !== undefined) {
                    NoteNav.openWrite(this.item.id)
                  }
                }
              })
              AppButton({
                label: '让它离开',
                variant: 'secondary',
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
          .align(Alignment.Top)
        }
      }

      if (this.confirmDelete) {
        Column() {
          Column({ space: 16 }) {
            Text('确定要让这篇心笺离开吗？')
              .fontSize(Theme.type.title3)
              .fontWeight(FontWeight.Medium)
              .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
              .width('100%')
            Text('离开之后，它不会再出现在你的手账里。')
              .fontSize(Theme.type.subhead)
              .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
              .width('100%')
            AppButton({ label: '留下它', onTap: (): void => { this.confirmDelete = false } })
            AppButton({
              label: '删除',
              variant: 'danger',
              onTap: (): void => { void this.doDelete() }
            })
          }
          .width('100%')
          .padding(24)
          .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
          .borderRadius(Theme.radius.lg)
        }
        .width('100%')
        .height('100%')
        .padding(Theme.space.pageX)
        .justifyContent(FlexAlign.Center)
        .backgroundColor(Theme.colors().overlayScrim)
      }

      if (this.toastText.length > 0) {
        Text(this.toastText)
          .fontSize(Theme.type.footnote)
          .fontColor(Theme.colors().brandOnPrimary)
          .padding({ left: 16, right: 16, top: 10, bottom: 10 })
          .backgroundColor(Theme.colors().brandPrimary)
          .borderRadius(Theme.radius.pill)
          .margin({ top: 24 })
      }
    }
    .width('100%')
    .height('100%')
  }
}
