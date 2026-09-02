import { Theme } from '../design-system/Theme'
import { AppCard } from '../design-system/AppCard'
import { AppButton } from '../design-system/AppButton'
import { AppEmpty } from '../design-system/AppEmpty'
import { AppLoading } from '../design-system/AppLoading'
import { DetailShell } from './DetailShell'
import { CreateFavoriteRequest, JournalItem } from '../../models/JournalModels'
import { JournalBizService } from '../../services/JournalBizService'
import { JournalMedia } from '../../services/JournalMedia'
import { JournalDetailNav } from '../../services/JournalDetailNav'
import { AuthService } from '../../services/AuthService'

@Component
export struct FeaturedDetailPane {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop itemId: string = ''
  @Prop @Watch('onItemIdChange') refreshToken: number = 0
  onRequireAuth: () => void = () => {}
  @State item: JournalItem | undefined = undefined
  @State loading: boolean = true
  @State toastText: string = ''
  @State alreadyFavorited: boolean = false
  @StorageLink('currentUsername') currentUsername: string = ''

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
    this.item = await JournalBizService.findFeatured(this.itemId)
    if (this.item !== undefined && AuthService.isLoggedIn()) {
      this.alreadyFavorited = await JournalBizService.hasFavoriteRef(
        `featured:${this.item.id}`,
        this.currentUsername
      )
    } else {
      this.alreadyFavorited = false
    }
    this.loading = false
  }

  private async handleFavorite(): Promise<void> {
    if (!AuthService.requireAuth('add_favorite')) {
      this.onRequireAuth()
      return
    }
    if (this.item === undefined) {
      return
    }
    if (this.alreadyFavorited) {
      this.showToast('该回忆已在语句收藏中')
      return
    }
    const req = new CreateFavoriteRequest()
    req.kind = 'text'
    req.title = this.item.title
    req.content = this.item.summary.length > 0 ? this.item.summary : this.item.body
    req.coverKey = this.item.coverKey
    req.sourceRefId = `featured:${this.item.id}`
    const created = await JournalBizService.createFavorite(req)
    if (created !== undefined) {
      this.alreadyFavorited = true
      this.showToast('已加入语句收藏')
    } else {
      this.showToast(JournalBizService.lastError.length > 0
        ? JournalBizService.lastError
        : '收藏失败，请稍后重试')
    }
  }

  build() {
    Stack() {
      if (this.loading) {
        AppLoading({ label: '加载回忆…' })
      } else if (this.item === undefined) {
        AppEmpty({ title: '回忆不存在', description: '可能已被删除或网络异常' })
      } else {
        DetailShell({
          title: '精选回忆',
          onClose: () => JournalDetailNav.close(),
          body: () => { this.DetailBody() }
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
  DetailBody() {
    if (this.item === undefined) {
      Column()
    } else {
      Column({ space: Theme.space.s4 }) {
        Stack({ alignContent: Alignment.BottomStart }) {
          Image(JournalMedia.coverMedia(this.item.coverKey))
            .width('100%')
            .height(220)
            .objectFit(ImageFit.Cover)
            .borderRadius({ topLeft: Theme.radius.xl, topRight: Theme.radius.xl })
          Column()
            .width('100%')
            .height(220)
            .linearGradient({
              angle: 180,
              colors: [['rgba(92,107,115,0)', 0], ['rgba(92,107,115,0.78)', 1]]
            })
            .borderRadius({ topLeft: Theme.radius.xl, topRight: Theme.radius.xl })
          Column({ space: 4 }) {
            if (this.item.recordDate.length > 0) {
              Text(this.item.recordDate)
                .fontSize(Theme.type.caption)
                .fontColor(Theme.colors().textOnInverse)
            }
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

        Column({ space: Theme.space.s4 }) {
          AppCard({ title: '摘要', variant: 'plain' }) {
            Text(this.item.summary)
              .fontSize(Theme.type.body)
              .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
              .width('100%')
          }
          AppCard({ title: '正文', variant: 'plain' }) {
            Text(this.item.body.length > 0 ? this.item.body : this.item.summary)
              .fontSize(Theme.type.body)
              .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
              .width('100%')
              .lineHeight(24)
          }
          AppButton({
            label: this.alreadyFavorited ? '已在语句收藏' : '收藏这段回忆',
            disabled: this.alreadyFavorited,
            onTap: (): void => { void this.handleFavorite() }
          })
        }
        .width('100%')
        .padding({ left: Theme.space.pageX, right: Theme.space.pageX })
      }
    }
  }
}
