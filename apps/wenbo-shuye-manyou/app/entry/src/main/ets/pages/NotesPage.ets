import { Theme } from '../components/design-system/Theme'
import { AppEmpty } from '../components/design-system/AppEmpty'
import { AppIcon } from '../components/design-system/AppIcon'
import { RoamNote, RoamTime } from '../models/RoamModels'
import { RoamDetailNav } from '../services/RoamDetailNav'
import { RoamStore } from '../services/RoamStore'

@Component
export struct NotesPage {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop @Watch('onRefreshTokenChange') refreshToken: number = 0
  @State notes: RoamNote[] = []

  aboutToAppear(): void {
    this.reload()
  }

  onRefreshTokenChange(): void {
    this.reload()
  }

  private reload(): void {
    this.notes = RoamStore.notesAll()
  }

  build() {
    Column() {
      Row({ space: Theme.space.s2 }) {
        Text('阅读笔记')
          .fontSize(Theme.type.title2)
          .fontWeight(FontWeight.Medium)
          .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
          .layoutWeight(1)
        Column() {
          AppIcon({ name: 'settings', iconSize: Theme.icon.md, color: Theme.colors().textPrimary })
        }
        .width(44)
        .height(44)
        .justifyContent(FlexAlign.Center)
        .onClick((): void => { RoamDetailNav.openSettings() })
      }
      .width('100%')
      .padding({
        left: Theme.space.pageX,
        right: Theme.space.pageX,
        top: Theme.space.pageY
      })

      if (this.notes.length === 0) {
        AppEmpty({
          title: '还没有笔记',
          description: '在节选详情页写下感受，笔记仅保存在本机。'
        }).layoutWeight(1)
      } else {
        List() {
          ForEach(this.notes, (note: RoamNote) => {
            ListItem() {
              Column({ space: 6 }) {
                Text(note.bookTitle)
                  .fontSize(Theme.type.subhead)
                  .fontWeight(FontWeight.Medium)
                  .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
                  .width('100%')
                Text(note.previewLine())
                  .fontSize(Theme.type.body)
                  .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
                  .maxLines(2)
                  .width('100%')
                Text(RoamTime.formatDateTime(note.updatedAt))
                  .fontSize(Theme.type.caption)
                  .fontColor(Theme.colors().textTertiary)
                  .width('100%')
              }
              .width('100%')
              .padding(Theme.space.s4)
              .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
              .borderRadius(Theme.radius.md)
              .onClick((): void => { RoamDetailNav.openNote(note.id) })
            }
            .padding({ left: Theme.space.pageX, right: Theme.space.pageX, bottom: Theme.space.s3 })
          }, (note: RoamNote) => note.id)
        }
        .layoutWeight(1)
        .scrollBar(BarState.Off)
        .edgeEffect(EdgeEffect.Spring)
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfacePage : Theme.colors().surfacePage)
  }
}
