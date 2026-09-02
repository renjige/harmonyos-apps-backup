import { Theme } from '../design-system/Theme'
import { AppCard } from '../design-system/AppCard'
import { AppButton } from '../design-system/AppButton'
import { AppEmpty } from '../design-system/AppEmpty'
import { AppLoading } from '../design-system/AppLoading'
import { DetailShell } from './DetailShell'
import { CreateBookRequest, CreateQuoteRequest, FeaturedItem } from '../../models/ReadingModels'
import { ReadingBizService } from '../../services/ReadingBizService'
import { ReadingMedia } from '../../services/ReadingMedia'
import { ReadingDetailNav } from '../../services/ReadingDetailNav'
import { AuthService } from '../../services/AuthService'

@Component
export struct FeaturedDetailPane {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop itemId: string = ''
  @Prop @Watch('onItemIdChange') refreshToken: number = 0
  onRequireAuth: () => void = () => {}
  @State item: FeaturedItem | undefined = undefined
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
    this.item = await ReadingBizService.findFeatured(this.itemId)
    this.loading = false
  }

  private async handleAddQuote(): Promise<void> {
    if (!AuthService.requireAuth('add_quote')) {
      this.onRequireAuth()
      return
    }
    if (this.item === undefined) {
      return
    }
    const req = new CreateQuoteRequest()
    req.title = this.item.title
    req.content = this.item.body.length > 0 ? this.item.body : this.item.summary
    req.source = this.item.source.length > 0 ? this.item.source : this.item.author
    req.tags = this.item.tags
    const created = await ReadingBizService.createQuote(req)
    if (created !== undefined) {
      this.showToast('已收藏至精选')
    } else {
      this.showToast('收藏失败，请稍后重试')
    }
  }

  private async handleAddBook(): Promise<void> {
    if (!AuthService.requireAuth('create_book')) {
      this.onRequireAuth()
      return
    }
    if (this.item === undefined) {
      return
    }
    const req = new CreateBookRequest()
    req.title = this.item.title
    req.author = this.item.author
    req.summary = this.item.summary
    req.coverKey = this.item.coverKey
    req.tags = this.item.tags
    req.readStatus = 'unread'
    const created = await ReadingBizService.createBook(req)
    if (created !== undefined) {
      this.showToast('已加入书架，可开始记录进度')
    } else {
      this.showToast('加入失败，请稍后重试')
    }
  }

  build() {
    Stack() {
      if (this.loading) {
        AppLoading({ label: '加载精选…' })
      } else if (this.item === undefined) {
        AppEmpty({ title: '内容不存在', description: '可能已被删除或网络异常' })
      } else {
        DetailShell({
          title: '今日明悟',
          onClose: (): void => { ReadingDetailNav.close() },
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
  DetailBody() {
    if (this.item === undefined) {
      Column()
    } else {
      this.FeaturedBody(this.item)
    }
  }

  @Builder
  FeaturedBody(row: FeaturedItem) {
    Column({ space: Theme.space.s4 }) {
        Stack({ alignContent: Alignment.BottomStart }) {
          Image(ReadingMedia.coverMedia(row.coverKey))
            .width('100%')
            .height(220)
            .objectFit(ImageFit.Cover)
            .borderRadius({ topLeft: Theme.radius.xl, topRight: Theme.radius.xl })
          Column()
            .width('100%')
            .height(220)
            .linearGradient({
              angle: 180,
              colors: [['rgba(26,42,58,0)', 0], ['rgba(26,42,58,0.82)', 1]]
            })
            .borderRadius({ topLeft: Theme.radius.xl, topRight: Theme.radius.xl })
          Column({ space: 4 }) {
            if (row.author.length > 0) {
              Text(row.author)
                .fontSize(Theme.type.caption)
                .fontColor(Theme.colors().textOnInverse)
            }
            Text(row.title)
              .fontSize(Theme.type.title2)
              .fontWeight(FontWeight.Bold)
              .fontColor(Theme.colors().textOnInverse)
          }
          .padding(Theme.space.s5)
          .alignItems(HorizontalAlign.Start)
        }
        .width('100%')
        .padding({ left: Theme.space.pageX, right: Theme.space.pageX })

        if (row.tags.length > 0) {
          Row({ space: 8 }) {
            ForEach(row.tags, (tag: string) => {
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

        Column() {
          AppCard({ title: '摘要', variant: 'plain' }) {
            Text(row.summary)
              .fontSize(Theme.type.body)
              .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
              .width('100%')
          }
        }
        .width('100%')
        .padding({ left: Theme.space.pageX, right: Theme.space.pageX })

        Column() {
          AppCard({ title: '正文', variant: 'plain' }) {
            Text(row.body.length > 0 ? row.body : row.summary)
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
            label: '加入书架',
            onTap: (): void => { void this.handleAddBook() }
          })
          AppButton({
            label: '收藏至精选',
            variant: 'secondary',
            onTap: (): void => { void this.handleAddQuote() }
          })
        }
        .width('100%')
        .padding({ left: Theme.space.pageX, right: Theme.space.pageX })
      }
  }
}
