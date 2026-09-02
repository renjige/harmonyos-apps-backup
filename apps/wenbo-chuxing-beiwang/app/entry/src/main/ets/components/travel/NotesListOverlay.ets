import { Theme } from '../design-system/Theme'
import { AppButton } from '../design-system/AppButton'
import { AppEmpty } from '../design-system/AppEmpty'
import { AppIcon } from '../design-system/AppIcon'
import { NoteItem } from '../../models/TravelModels'

@Component
export struct NotesListOverlay {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop notes: NoteItem[] = []
  onClose: () => void = () => {}
  onCreate: () => void = () => {}

  aboutToAppear(): void {
    AppStorage.setOrCreate('tabBarHidden', true)
  }

  private close(): void {
    AppStorage.setOrCreate('tabBarHidden', false)
    this.onClose()
  }

  build() {
    Column() {
      Row() {
        Row() {
          AppIcon({ name: 'chevron', iconSize: Theme.icon.md })
        }
        .width(44)
        .height(44)
        .justifyContent(FlexAlign.Center)
        .rotate({ angle: 180 })
        .onClick(() => this.close())
        Text('旅途备忘')
          .fontSize(Theme.type.title3)
          .fontWeight(FontWeight.Bold)
          .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
      }
      .width('100%')
      .padding({ left: 8, right: Theme.space.pageX, top: Theme.space.s2 })

      Scroll() {
        Column({ space: Theme.space.s3 }) {
          AppButton({ label: '写一条备忘', onTap: () => this.onCreate() })
          if (this.notes.length === 0) {
            AppEmpty({
              title: '还没有备忘',
              description: '记下交通、住宿、集合地点或需要提醒同伴的事项',
              actionLabel: '立即记录',
              onAction: () => this.onCreate()
            })
          } else {
            ForEach(this.notes, (note: NoteItem) => {
              Column({ space: 6 }) {
                Text(note.title)
                  .fontSize(Theme.type.subtitleM)
                  .fontWeight(FontWeight.Medium)
                  .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
                  .width('100%')
                Text(note.body.length > 0 ? note.body : '未填写正文')
                  .fontSize(Theme.type.caption)
                  .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
                  .width('100%')
                if (note.updatedAt.length > 0) {
                  Text(note.updatedAt)
                    .fontSize(Theme.type.captionM)
                    .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
                    .width('100%')
                }
              }
              .width('100%')
              .padding(Theme.space.s4)
              .alignItems(HorizontalAlign.Start)
              .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
              .borderRadius(Theme.radius.xl)
            }, (note: NoteItem) => note.id)
          }
        }
        .width('100%')
        .padding({ left: Theme.space.pageX, right: Theme.space.pageX, bottom: Theme.space.s10 })
      }
      .layoutWeight(1)
      .scrollBar(BarState.Off)
    }
    .width('100%')
    .height('100%')
    .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfacePage : Theme.colors().surfacePage)
  }
}
