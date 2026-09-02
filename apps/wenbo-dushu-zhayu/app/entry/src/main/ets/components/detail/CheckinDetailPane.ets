import { Theme } from '../design-system/Theme'
import { AppCard } from '../design-system/AppCard'
import { AppButton } from '../design-system/AppButton'
import { AppLoading } from '../design-system/AppLoading'
import { DetailShell } from './DetailShell'
import { DetailMissingPane } from './DetailMissingPane'
import { CheckinItem } from '../../models/ReadingModels'
import { ReadingBizService } from '../../services/ReadingBizService'
import { ReadingMedia } from '../../services/ReadingMedia'
import { ReadingDetailNav } from '../../services/ReadingDetailNav'

@Component
export struct CheckinDetailPane {
  @Prop itemId: string = ''
  @Prop @Watch('onItemIdChange') refreshToken: number = 0
  onDeleted: () => void = () => {}
  @State item: CheckinItem | undefined = undefined
  @State loading: boolean = true
  @State toastText: string = ''

  aboutToAppear(): void {
    void this.loadItem()
  }

  onItemIdChange(): void {
    void this.loadItem()
  }

  private async loadItem(): Promise<void> {
    this.loading = true
    this.item = await ReadingBizService.findCheckin(this.itemId)
    this.loading = false
  }

  private async handleDelete(): Promise<void> {
    if (this.item === undefined) {
      ReadingDetailNav.close()
      return
    }
    const ok = await ReadingBizService.deleteCheckin(this.item.id)
    if (ok) {
      this.onDeleted()
      ReadingDetailNav.close()
      return
    }
    this.toastText = '删除失败'
    setTimeout(() => { this.toastText = '' }, 2000)
  }

  build() {
    Stack() {
      if (this.loading) {
        AppLoading({ label: '加载打卡…' })
      } else if (this.item === undefined) {
        DetailMissingPane({
          title: '阅读打卡',
          emptyTitle: '打卡不存在',
          emptyDescription: '可能已被删除，请返回继续使用'
        })
      } else {
        DetailShell({
          title: '阅读打卡',
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
        Image(ReadingMedia.coverMedia('checkin_morning'))
          .width('100%')
          .height(160)
          .objectFit(ImageFit.Cover)
          .borderRadius(Theme.radius.xl)
          .margin({ left: Theme.space.pageX, right: Theme.space.pageX })
        Column() {
          AppCard({ title: '打卡摘要', variant: 'plain' }) {
            Text(`${this.item.recordDate} · 阅读 ${this.item.readingMinutes} 分钟`)
              .fontSize(Theme.type.body)
              .fontColor(Theme.colors().textPrimary)
              .width('100%')
          }
        }
        .padding({ left: Theme.space.pageX, right: Theme.space.pageX })
        .width('100%')
        AppButton({
          label: '删除这次打卡',
          variant: 'danger',
          onTap: (): void => { void this.handleDelete() }
        })
          .padding({ left: Theme.space.pageX, right: Theme.space.pageX })
      }
    }
  }
}
