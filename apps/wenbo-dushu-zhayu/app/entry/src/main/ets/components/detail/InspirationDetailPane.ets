import { Theme } from '../design-system/Theme'
import { AppCard } from '../design-system/AppCard'
import { AppButton } from '../design-system/AppButton'
import { AppLoading } from '../design-system/AppLoading'
import { DetailShell } from './DetailShell'
import { DetailMissingPane } from './DetailMissingPane'
import { CreateNoteRequest, InspirationItem } from '../../models/ReadingModels'
import { ReadingBizService } from '../../services/ReadingBizService'
import { ReadingMedia } from '../../services/ReadingMedia'
import { ReadingDetailNav } from '../../services/ReadingDetailNav'
import { AuthService } from '../../services/AuthService'

@Component
export struct InspirationDetailPane {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop itemId: string = ''
  @Prop @Watch('onItemIdChange') refreshToken: number = 0
  onRequireAuth: () => void = () => {}
  onChanged: () => void = () => {}
  @State item: InspirationItem | undefined = undefined
  @State loading: boolean = true
  @State toastText: string = ''

  aboutToAppear(): void {
    void this.loadItem()
  }

  onItemIdChange(): void {
    void this.loadItem()
  }

  private showToast(msg: string): void {
    this.toastText = msg
    setTimeout(() => { this.toastText = '' }, 2400)
  }

  private async loadItem(): Promise<void> {
    this.loading = true
    this.item = await ReadingBizService.findInspiration(this.itemId)
    this.loading = false
  }

  private async handleToNote(): Promise<void> {
    if (!AuthService.requireAuth('create_note')) {
      this.onRequireAuth()
      return
    }
    if (this.item === undefined) {
      return
    }
    const req = new CreateNoteRequest()
    req.title = this.item.title
    req.body = this.item.content
    req.summary = this.item.content.substring(0, 80)
    req.tags = this.item.tags
    req.kind = 'insight'
    const created = await ReadingBizService.createNote(req)
    if (created !== undefined) {
      this.onChanged()
      this.showToast('已写成读书笔记')
      return
    }
    this.showToast('保存失败，请稍后重试')
  }

  private async handleDelete(): Promise<void> {
    if (this.item === undefined) {
      return
    }
    const ok = await ReadingBizService.deleteInspiration(this.item.id)
    if (ok) {
      this.onChanged()
      ReadingDetailNav.close()
    }
  }

  build() {
    Stack() {
      if (this.loading) {
        AppLoading({ label: '加载灵感…' })
      } else if (this.item === undefined) {
        DetailMissingPane({
          title: '灵感收藏',
          emptyTitle: '灵感不存在',
          emptyDescription: '可能已被删除，请返回继续使用'
        })
      } else {
        DetailShell({
          title: '灵感收藏',
          onClose: (): void => { ReadingDetailNav.close() },
          body: (): void => { this.DetailBody() }
        })
      }
      if (this.toastText.length > 0) {
        Text(this.toastText)
          .fontSize(Theme.type.footnote)
          .fontColor(Theme.colors().brandOnPrimary)
          .padding(10)
          .backgroundColor(Theme.colors().brandPrimary)
          .borderRadius(Theme.radius.pill)
          .margin({ top: Theme.space.s6 })
      }
    }
    .width('100%')
    .height('100%')
  }

  @Builder
  DetailBody() {
    if (this.item === undefined) {
      Column()
    } else {
      Column({ space: Theme.space.s4 }) {
        Image(ReadingMedia.coverMedia(this.item.coverKey))
          .width('100%')
          .height(160)
          .objectFit(ImageFit.Cover)
          .borderRadius(Theme.radius.xl)
          .margin({ left: Theme.space.pageX, right: Theme.space.pageX })
        Column() {
          AppCard({ title: this.item.title, variant: 'plain' }) {
            Text(this.item.content)
              .fontSize(Theme.type.body)
              .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
              .lineHeight(24)
              .width('100%')
          }
        }
        .padding({ left: Theme.space.pageX, right: Theme.space.pageX })
        .width('100%')
        Column({ space: Theme.space.s3 }) {
          AppButton({
            label: '写成读书笔记',
            onTap: (): void => { void this.handleToNote() }
          })
          AppButton({
            label: '删除灵感',
            variant: 'danger',
            onTap: (): void => { void this.handleDelete() }
          })
        }
        .padding({ left: Theme.space.pageX, right: Theme.space.pageX })
        .width('100%')
      }
    }
  }
}
