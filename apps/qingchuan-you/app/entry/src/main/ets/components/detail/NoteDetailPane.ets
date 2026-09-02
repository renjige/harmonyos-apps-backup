import { Theme } from '../design-system/Theme'
import { AppButton } from '../design-system/AppButton'
import { AppEmpty } from '../design-system/AppEmpty'
import { AppLoading } from '../design-system/AppLoading'
import { DetailShell } from './DetailShell'
import { NoteItem } from '../../models/ScenicModels'
import { ScenicBizService } from '../../services/ScenicBizService'
import { ScenicDetailNav } from '../../services/ScenicDetailNav'
import { ScenicMedia } from '../../services/ScenicMedia'
import { AuthService } from '../../services/AuthService'

@Component
export struct NoteDetailPane {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop @Watch('onNoteIdChange') noteId: string = ''
  @Prop @Watch('onNoteIdChange') refreshToken: number = 0
  @State item: NoteItem | undefined = undefined
  @State loading: boolean = true
  @State toastText: string = ''
  onRequireAuth: () => void = () => {}

  aboutToAppear(): void {
    void this.reload()
  }

  onNoteIdChange(): void {
    void this.reload()
  }

  private async reload(): Promise<void> {
    this.loading = true
    this.item = await ScenicBizService.findNote(this.noteId)
    this.loading = false
  }

  private current(): NoteItem {
    return this.item !== undefined ? this.item : new NoteItem()
  }

  private async like(): Promise<void> {
    const ok = await ScenicBizService.likeNote(this.noteId)
    if (ok) {
      this.toastText = '已点赞'
      void this.reload()
    }
    setTimeout(() => { this.toastText = '' }, 1800)
  }

  private async fav(): Promise<void> {
    if (!AuthService.requireAuth('add_favorite')) {
      this.onRequireAuth()
      return
    }
    const n = this.current()
    await ScenicBizService.toggleFavorite('note', n.id, n.title, n.coverKey)
    this.toastText = '已更新收藏'
    setTimeout(() => { this.toastText = '' }, 1800)
  }

  build() {
    Stack({ alignContent: Alignment.Top }) {
      if (this.loading) {
        Column() {
          AppLoading({ label: '打开笔记' })
        }.width('100%').height('100%').justifyContent(FlexAlign.Center)
      } else if (this.item === undefined) {
        DetailShell({ title: '笔记', onClose: () => ScenicDetailNav.close() }) {
          AppEmpty({ title: '笔记不存在', actionLabel: '返回', onAction: () => ScenicDetailNav.close() })
        }
      } else {
        DetailShell({ title: this.current().title, contentKey: this.current().id, onClose: () => ScenicDetailNav.close() }) {
          Column({ space: Theme.space.s4 }) {
            Image(ScenicMedia.resource(this.current().coverKey))
              .width('100%').height(200).objectFit(ImageFit.Cover)
              .borderRadius(Theme.radius.lg)
              .margin({ left: Theme.space.pageX, right: Theme.space.pageX })
            Column({ space: 8 }) {
              Text(`${this.current().userName} · ${this.current().destName}`)
                .fontSize(Theme.type.footnote).fontColor(this.themeEpoch >= 0 ? Theme.colors().brandPrimary : Theme.colors().brandPrimary).width('100%')
              Text(this.current().likesLabel())
                .fontSize(Theme.type.caption).fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary).width('100%')
              Text(this.current().body)
                .fontSize(Theme.type.body).fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary).width('100%')
            }
            .padding(16).margin({ left: Theme.space.pageX, right: Theme.space.pageX })
            .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard).borderRadius(Theme.radius.md)
            Column({ space: 10 }) {
              AppButton({ label: '点赞', onTap: (): void => { void this.like() } })
              AppButton({ label: '收藏这篇笔记', variant: 'secondary', onTap: (): void => { void this.fav() } })
            }
            .padding({ left: Theme.space.pageX, right: Theme.space.pageX, bottom: Theme.space.s6 })
          }
        }
      }
      if (this.toastText.length > 0) {
        Column() {
          Text(this.toastText).fontSize(Theme.type.footnote).fontColor(Theme.colors().brandOnPrimary)
            .padding({ left: 16, right: 16, top: 10, bottom: 10 })
            .backgroundColor(Theme.colors().brandPrimary).borderRadius(Theme.radius.pill)
        }.width('100%').padding({ top: Theme.space.s6 }).alignItems(HorizontalAlign.Center).zIndex(30)
      }
    }
    .width('100%').height('100%')
  }
}
