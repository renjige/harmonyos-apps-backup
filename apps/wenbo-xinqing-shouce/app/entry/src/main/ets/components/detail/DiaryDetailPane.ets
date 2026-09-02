import { Theme } from '../design-system/Theme'
import { AppCard } from '../design-system/AppCard'
import { AppButton } from '../design-system/AppButton'
import { AppEmpty } from '../design-system/AppEmpty'
import { AppLoading } from '../design-system/AppLoading'
import { DetailShell } from './DetailShell'
import { CreateFavoriteRequest, JournalItem } from '../../models/JournalModels'
import { JournalBizService } from '../../services/JournalBizService'
import { JournalHeroImage } from '../journal/JournalHeroImage'
import { JournalDetailNav } from '../../services/JournalDetailNav'
import { AuthService } from '../../services/AuthService'

@Component
export struct DiaryDetailPane {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop itemId: string = ''
  @Prop @Watch('onItemIdChange') refreshToken: number = 0
  onRequireAuth: () => void = () => {}
  onDeleted: () => void = () => {}
  @State item: JournalItem | undefined = undefined
  @State loading: boolean = true
  @State notFound: boolean = false
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
    this.notFound = false
    this.item = await JournalBizService.findDiary(this.itemId)
    this.loading = false
    if (this.item === undefined) {
      this.notFound = true
    }
  }

  private closeDetail(): void {
    JournalDetailNav.close()
  }

  private async handleDelete(): Promise<void> {
    if (this.item === undefined) {
      return
    }
    const targetId = this.item.id
    const ok = await JournalBizService.deleteDiary(targetId)
    if (ok) {
      this.item = undefined
      this.notFound = true
      this.closeDetail()
      this.onDeleted()
      return
    }
    this.showToast('删除失败，请稍后重试')
  }

  private async handleFavorite(): Promise<void> {
    if (!AuthService.requireAuth('add_favorite')) {
      this.onRequireAuth()
      return
    }
    if (this.item === undefined) {
      return
    }
    const req = new CreateFavoriteRequest()
    req.kind = 'text'
    req.title = this.item.title
    req.content = this.item.body.length > 0 ? this.item.body : this.item.summary
    const created = await JournalBizService.createFavorite(req)
    if (created !== undefined) {
      this.showToast('已加入温暖收藏')
    } else {
      this.showToast('收藏失败，请稍后重试')
    }
  }

  build() {
    Stack() {
      if (this.loading) {
        AppLoading({ label: '加载记录…' })
      } else if (this.notFound) {
        DetailShell({
          title: '我的记录',
          onClose: (): void => { this.closeDetail() },
          body: () => { this.NotFoundBody() }
        })
      } else if (this.item === undefined) {
        DetailShell({
          title: '我的记录',
          onClose: (): void => { this.closeDetail() },
          body: () => { this.NotFoundBody() }
        })
      } else {
        DetailShell({
          title: '我的记录',
          onClose: (): void => { this.closeDetail() },
          body: (): void => { this.DetailBody() }
        })
      }

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

  @Builder
  NotFoundBody() {
    Column() {
      AppEmpty({
        title: '记录不存在',
        description: '该记录可能已删除，请返回列表重新选择',
        actionLabel: '返回',
        onAction: (): void => { this.closeDetail() }
      })
    }
    .width('100%')
    .padding({ left: Theme.space.pageX, right: Theme.space.pageX, top: Theme.space.s6 })
  }

  @Builder
  DetailBody() {
    if (this.item === undefined) {
      Column()
    } else {
      Column({ space: Theme.space.s4 }) {
        Stack({ alignContent: Alignment.BottomStart }) {
          JournalHeroImage({
            coverKey: this.item.coverKey,
            fallbackKey: 'hero_morning_coffee',
            heroHeight: 200
          })
          Column()
            .width('100%')
            .height(200)
            .linearGradient({
              angle: 180,
              colors: [['rgba(92,107,115,0)', 0], ['rgba(92,107,115,0.78)', 1]]
            })
            .borderRadius({ topLeft: Theme.radius.xl, topRight: Theme.radius.xl })
          Column({ space: 4 }) {
            Text(this.item.recordDate.length > 0 ? this.item.recordDate : '心情记录')
              .fontSize(Theme.type.caption)
              .fontColor(Theme.colors().textOnInverse)
            Text(this.item.title)
              .fontSize(Theme.type.title2)
              .fontWeight(FontWeight.Bold)
              .fontColor(Theme.colors().textOnInverse)
          }
          .padding(Theme.space.s5)
          .alignItems(HorizontalAlign.Start)
        }
        .width('100%')
        .padding({ left: Theme.space.pageX, right: Theme.space.pageX })

        if (this.item.tags.length > 0) {
          Row({ space: 8 }) {
            ForEach(this.item.tags, (tag: string) => {
              Text(tag)
                .fontSize(Theme.type.caption)
                .fontColor(this.themeEpoch >= 0 ? Theme.colors().brandPrimary : Theme.colors().brandPrimary)
                .padding({ left: 10, right: 10, top: 4, bottom: 4 })
                .backgroundColor(Theme.colors().brandPrimaryContainer)
                .borderRadius(Theme.radius.pill)
            }, (tag: string) => tag)
          }
          .width('100%')
          .padding({ left: Theme.space.pageX, right: Theme.space.pageX })
        }

        if (this.item.summary.length > 0) {
          Column() {
            AppCard({ title: '摘要', variant: 'plain' }) {
              Text(this.item.summary)
                .fontSize(Theme.type.body)
                .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
                .width('100%')
            }
          }
          .width('100%')
          .padding({ left: Theme.space.pageX, right: Theme.space.pageX })
        }

        Column() {
          AppCard({ title: '正文', variant: 'plain' }) {
            Text(this.item.body.length > 0 ? this.item.body : '（无正文）')
              .fontSize(Theme.type.body)
              .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
              .width('100%')
              .lineHeight(24)
          }
        }
        .width('100%')
        .padding({ left: Theme.space.pageX, right: Theme.space.pageX })

        Column({ space: Theme.space.s3 }) {
          AppButton({
            label: '加入温暖收藏',
            variant: 'secondary',
            onTap: (): void => { void this.handleFavorite() }
          })
          AppButton({
            label: '删除这条记录',
            variant: 'danger',
            onTap: (): void => { void this.handleDelete() }
          })
        }
        .width('100%')
        .padding({ left: Theme.space.pageX, right: Theme.space.pageX })
      }
    }
  }
}
