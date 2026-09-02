import { Theme } from '../design-system/Theme'
import { AppButton } from '../design-system/AppButton'
import { AppCard } from '../design-system/AppCard'
import { AppIcon } from '../design-system/AppIcon'
import { StudyNote } from '../../models/StudyModels'
import { StudyStore } from '../../services/StudyStore'
import { StudyMedia } from '../../services/StudyMedia'

@Component
export struct NoteDetailPane {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop @Watch('onNoteIdChange') noteId: string = ''
  @State item: StudyNote = new StudyNote()
  @State confirmDelete: boolean = false
  @State toastText: string = ''
  onClose: () => void = () => {}
  onChanged: () => void = () => {}
  onEdit: (id: string) => void = (_id: string) => {}

  aboutToAppear(): void {
    void this.load()
  }

  onNoteIdChange(): void {
    void this.load()
  }

  private async load(): Promise<void> {
    const found = await StudyStore.findNote(this.noteId)
    if (found !== undefined) {
      this.item = found
    }
  }

  private async doDelete(): Promise<void> {
    if (!this.confirmDelete) {
      this.confirmDelete = true
      this.toastText = '再点一次确认删除'
      setTimeout((): void => { this.toastText = '' }, 2200)
      return
    }
    await StudyStore.deleteNote(this.item.id)
    this.onChanged()
    this.onClose()
  }

  build() {
    Stack() {
      Column() {
        Row() {
          Row() {
            AppIcon({ name: 'close', iconSize: Theme.icon.lg, color: Theme.colors().textPrimary })
          }
          .width(48).height(48).justifyContent(FlexAlign.Center)
          .onClick((): void => { this.onClose() })
          Text('笔记详情')
            .fontSize(Theme.type.subtitleM)
            .fontWeight(FontWeight.Medium)
            .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
            .layoutWeight(1)
        }
        .width('100%')

        Scroll() {
          Column({ space: Theme.space.s4 }) {
            Stack({ alignContent: Alignment.BottomStart }) {
              Image(StudyMedia.resource(this.item.coverKey))
                .width('100%')
                .height(180)
                .objectFit(ImageFit.Cover)
              Column() {
                Blank()
                Column({ space: 6 }) {
                  Text(this.item.tags.length > 0 ? this.item.tags : '未分类')
                    .fontSize(Theme.type.caption)
                    .fontColor('#FFFFFF')
                  Text(this.item.title)
                    .fontSize(Theme.type.title3)
                    .fontWeight(FontWeight.Bold)
                    .fontColor('#FFFFFF')
                }
                .width('100%')
                .padding(Theme.space.s4)
                .linearGradient({
                  angle: 180,
                  colors: [['rgba(0,0,0,0)', 0], ['rgba(26,42,74,0.88)', 1]]
                })
              }
              .width('100%')
              .height(180)
            }
            .width('100%')
            .height(180)
            .borderRadius(Theme.radius.md)
            .clip(true)

            AppCard() {
              Text(StudyStore.timeLabel(this.item.updatedAt))
                .fontSize(Theme.type.bodyS)
                .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
                .width('100%')
            }

            AppCard({ title: '摘要' }) {
              Text(this.item.preview())
                .fontSize(Theme.type.body)
                .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
                .width('100%')
            }

            Text(this.item.body.length > 0 ? this.item.body : '尚未填写正文')
              .fontSize(Theme.type.body)
              .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
              .width('100%')
              .lineHeight(22)

            AppButton({ label: '编辑笔记', onTap: (): void => { this.onEdit(this.item.id) } })
            AppButton({
              label: this.confirmDelete ? '再点确认删除' : '删除笔记',
              variant: 'danger',
              onTap: (): void => { void this.doDelete() }
            })
          }
          .padding({
            left: Theme.space.pageX,
            right: Theme.space.pageX,
            bottom: Theme.space.s10
          })
        }
        .layoutWeight(1)
      }
      .width('100%')
      .height('100%')
      .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfacePage : Theme.colors().surfacePage)

      if (this.toastText.length > 0) {
        Text(this.toastText)
          .fontSize(Theme.type.bodyS)
          .fontColor('#FFFFFF')
          .padding(12)
          .backgroundColor(Theme.colors().brandPrimary)
          .borderRadius(12)
          .margin({ top: 16 })
      }
    }
    .width('100%')
    .height('100%')
    .alignContent(Alignment.Top)
  }
}
