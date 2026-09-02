import { Theme } from '../components/design-system/Theme'
import { AppEmpty } from '../components/design-system/AppEmpty'
import { AppLoading } from '../components/design-system/AppLoading'
import { NoteCard } from '../components/scenic/NoteCard'
import { NoteItem } from '../models/ScenicModels'
import { ScenicBizService } from '../services/ScenicBizService'
import { ScenicDetailNav } from '../services/ScenicDetailNav'
import { AuthService } from '../services/AuthService'

@Component
export struct CommunityPage {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop @Watch('onRefreshTokenChange') refreshToken: number = 0
  @State loading: boolean = true
  @State notes: NoteItem[] = []
  onRequireAuth: () => void = () => {}

  aboutToAppear(): void {
    void this.reload()
  }

  onRefreshTokenChange(): void {
    void this.reload()
  }

  private async reload(): Promise<void> {
    this.loading = true
    this.notes = await ScenicBizService.loadNotes()
    this.loading = false
  }

  private publish(): void {
    if (!AuthService.requireAuth('publish_note')) {
      this.onRequireAuth()
      return
    }
    ScenicDetailNav.openNoteNew('', '', 'note_westlake')
  }

  build() {
    Column() {
      Row() {
        Text('社区')
          .fontSize(Theme.type.title3)
          .fontWeight(FontWeight.Bold)
          .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
          .layoutWeight(1)
        Text('发布')
          .fontSize(Theme.type.caption)
          .fontColor(Theme.colors().brandOnPrimary)
          .padding({ left: 12, right: 12, top: 8, bottom: 8 })
          .backgroundColor(Theme.colors().brandPrimary)
          .borderRadius(Theme.radius.pill)
          .onClick(() => this.publish())
      }
      .width('100%')
      .padding({ left: Theme.space.pageX, right: Theme.space.pageX, top: 12, bottom: 8 })

      if (this.loading) {
        AppLoading({ label: '打开笔记' }).layoutWeight(1)
      } else if (this.notes.length === 0) {
        AppEmpty({
          title: '还没有笔记',
          description: '精选笔记来自平台；你也可以登录后发布',
          actionLabel: '重试',
          onAction: () => { void this.reload() }
        }).layoutWeight(1)
      } else {
        List({ space: 12 }) {
          ForEach(this.notes, (n: NoteItem) => {
            ListItem() {
              NoteCard({
                item: n,
                onTap: () => ScenicDetailNav.openNote(n.id)
              })
            }
          }, (n: NoteItem) => n.id)
        }
        .width('100%')
        .layoutWeight(1)
        .padding({ left: Theme.space.pageX, right: Theme.space.pageX, bottom: Theme.space.s6 })
        .edgeEffect(EdgeEffect.Spring)
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfacePage : Theme.colors().surfacePage)
  }
}
