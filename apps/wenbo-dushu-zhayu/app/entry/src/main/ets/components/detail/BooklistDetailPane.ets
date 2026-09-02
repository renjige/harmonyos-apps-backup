import { Theme } from '../design-system/Theme'
import { AppCard } from '../design-system/AppCard'
import { AppButton } from '../design-system/AppButton'
import { AppLoading } from '../design-system/AppLoading'
import { DetailShell } from './DetailShell'
import { DetailMissingPane } from './DetailMissingPane'
import { BooklistItem } from '../../models/ReadingModels'
import { ReadingBizService } from '../../services/ReadingBizService'
import { ReadingMedia } from '../../services/ReadingMedia'
import { ReadingDetailNav } from '../../services/ReadingDetailNav'
import { AuthService } from '../../services/AuthService'

@Component
export struct BooklistDetailPane {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop itemId: string = ''
  @Prop @Watch('onItemIdChange') refreshToken: number = 0
  onRequireAuth: () => void = () => {}
  onChanged: () => void = () => {}
  @State item: BooklistItem | undefined = undefined
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
    this.item = await ReadingBizService.findBooklist(this.itemId)
    this.loading = false
  }

  private async handleCollect(): Promise<void> {
    if (!AuthService.requireAuth('create_book')) {
      this.onRequireAuth()
      return
    }
    if (this.item === undefined) {
      return
    }
    const created = await ReadingBizService.collectBooklist(this.item.id)
    if (created !== undefined) {
      this.onChanged()
      this.showToast('已收藏到我的书单')
      return
    }
    this.showToast('收藏失败，请稍后重试')
  }

  private async handleDelete(): Promise<void> {
    if (this.item === undefined) {
      return
    }
    const ok = await ReadingBizService.deleteBooklist(this.item.id)
    if (ok) {
      this.onChanged()
      ReadingDetailNav.close()
    }
  }

  build() {
    Stack() {
      if (this.loading) {
        AppLoading({ label: '加载书单…' })
      } else if (this.item === undefined) {
        DetailMissingPane({
          title: '专题书单',
          emptyTitle: '书单不存在',
          emptyDescription: '请返回继续浏览其他书单'
        })
      } else {
        DetailShell({
          title: '专题书单',
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
        Stack({ alignContent: Alignment.BottomStart }) {
          Image(ReadingMedia.coverMedia(this.item.coverKey))
            .width('100%')
            .height(180)
            .objectFit(ImageFit.Cover)
            .borderRadius({ topLeft: Theme.radius.xl, topRight: Theme.radius.xl })
          Column()
            .width('100%')
            .height(180)
            .linearGradient({
              angle: 180,
              colors: Theme.heroScrimStops()
            })
            .borderRadius({ topLeft: Theme.radius.xl, topRight: Theme.radius.xl })
          Column({ space: 4 }) {
            Text(this.item.category)
              .fontSize(Theme.type.caption)
              .fontColor(Theme.heroSubtitleColor())
            Text(this.item.title)
              .fontSize(Theme.type.title2)
              .fontWeight(FontWeight.Bold)
              .fontColor(Theme.heroTitleColor())
          }
          .padding(Theme.space.s5)
        }
        .padding({ left: Theme.space.pageX, right: Theme.space.pageX })
        .width('100%')
        Column() {
          AppCard({ title: '书单说明', variant: 'plain' }) {
            Text(this.item.body.length > 0 ? this.item.body : this.item.summary)
              .fontSize(Theme.type.body)
              .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
              .lineHeight(24)
              .width('100%')
          }
        }
        .padding({ left: Theme.space.pageX, right: Theme.space.pageX })
        .width('100%')
        if (this.item.tags.length > 0) {
          Column() {
            AppCard({ title: '推荐书籍', variant: 'plain' }) {
              Text(this.item.tags.join('、'))
                .fontSize(Theme.type.body)
                .fontColor(Theme.colors().textPrimary)
                .width('100%')
            }
          }
          .padding({ left: Theme.space.pageX, right: Theme.space.pageX })
          .width('100%')
        }
        Column({ space: Theme.space.s3 }) {
          if (this.item.userId.length === 0) {
            AppButton({
              label: '收藏到我的书单',
              onTap: (): void => { void this.handleCollect() }
            })
          } else {
            AppButton({
              label: '删除我的书单',
              variant: 'danger',
              onTap: (): void => { void this.handleDelete() }
            })
          }
        }
        .padding({ left: Theme.space.pageX, right: Theme.space.pageX })
        .width('100%')
      }
    }
  }
}
