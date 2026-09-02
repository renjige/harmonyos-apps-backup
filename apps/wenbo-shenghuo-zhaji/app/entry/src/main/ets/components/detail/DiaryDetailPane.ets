import { Theme } from '../design-system/Theme'
import { AppCard } from '../design-system/AppCard'
import { AppButton } from '../design-system/AppButton'
import { AppEmpty } from '../design-system/AppEmpty'
import { AppLoading } from '../design-system/AppLoading'
import { DetailShell } from './DetailShell'
import { AlbumPhotoGrid } from '../journal/AlbumPhotoGrid'
import { CreateFavoriteRequest, JournalItem } from '../../models/JournalModels'
import { JournalBizService } from '../../services/JournalBizService'
import { JournalMedia } from '../../services/JournalMedia'
import { JournalImageCatalog } from '../../services/JournalImageCatalog'
import { JournalDetailNav } from '../../services/JournalDetailNav'
import { AuthService } from '../../services/AuthService'
import { MoodCatalog } from '../../services/MoodCatalog'
import { pasteboard } from '@kit.BasicServicesKit'

@Component
export struct DiaryDetailPane {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop itemId: string = ''
  @Prop @Watch('onItemIdChange') refreshToken: number = 0
  onRequireAuth: () => void = () => {}
  @State item: JournalItem | undefined = undefined
  @State loading: boolean = true
  @State toastText: string = ''
  @State alreadyFavorited: boolean = false

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

  private photoKeys(): string[] {
    if (this.item === undefined) {
      return []
    }
    return JournalItem.displayPhotoKeys(this.item)
  }

  private heroKey(): string {
    const keys = this.photoKeys()
    if (keys.length > 0) {
      return keys[0]
    }
    if (this.item !== undefined && this.item.coverKey.length > 0) {
      return this.item.coverKey
    }
    return 'hero_morning_coffee'
  }

  @Builder
  HeroImage() {
    if (JournalImageCatalog.isLocalKey(this.heroKey())) {
      Image(JournalImageCatalog.localUriFromKey(this.heroKey()))
        .width('100%')
        .height(200)
        .objectFit(ImageFit.Cover)
        .borderRadius({ topLeft: Theme.radius.xl, topRight: Theme.radius.xl })
    } else {
      Image(JournalMedia.coverMedia(this.heroKey()))
        .width('100%')
        .height(200)
        .objectFit(ImageFit.Cover)
        .borderRadius({ topLeft: Theme.radius.xl, topRight: Theme.radius.xl })
    }
  }

  private async loadItem(): Promise<void> {
    this.loading = true
    this.item = await JournalBizService.findDiary(this.itemId)
    this.alreadyFavorited = false
    if (this.item !== undefined && AuthService.isLoggedIn()) {
      this.alreadyFavorited = await JournalBizService.isFavorited(this.item.id)
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
      this.showToast('该札记已在美好收藏中')
      return
    }
    const req = new CreateFavoriteRequest()
    req.kind = 'text'
    req.title = this.item.title
    req.content = this.item.body.length > 0 ? this.item.body : this.item.summary
    req.sourceRefId = this.item.id
    const created = await JournalBizService.createFavorite(req)
    if (created !== undefined) {
      this.alreadyFavorited = true
      this.showToast('已加入美好收藏')
    } else {
      const dup = await JournalBizService.isFavorited(this.item.id)
      if (dup) {
        this.alreadyFavorited = true
        this.showToast('该札记已在美好收藏中')
      } else {
        this.showToast('收藏失败，请稍后重试')
      }
    }
  }

  private exportText(): string {
    if (this.item === undefined) {
      return ''
    }
    let text = `${this.item.title}\n`
    if (this.item.recordDate.length > 0) {
      text += `日期：${this.item.recordDate}\n`
    }
    if (this.item.subtitle.length > 0) {
      text += `足迹：${this.item.subtitle}\n`
    }
    if (this.item.category.length > 0) {
      text += `心情：${MoodCatalog.labelOf(this.item.category)}\n`
    }
    if (this.item.body.length > 0) {
      text += `\n${this.item.body}`
    } else if (this.item.summary.length > 0) {
      text += `\n${this.item.summary}`
    }
    return text
  }

  private handleExport(): void {
    const text = this.exportText()
    if (text.length === 0) {
      this.showToast('暂无可导出内容')
      return
    }
    try {
      const data = pasteboard.createData(pasteboard.MIMETYPE_TEXT_PLAIN, text)
      pasteboard.getSystemPasteboard().setData(data)
      this.showToast('札记正文已复制，可粘贴分享')
    } catch {
      this.showToast('复制失败，请稍后重试')
    }
  }

  build() {
    Stack() {
      if (this.loading) {
        AppLoading({ label: '加载札记…' })
      } else if (this.item === undefined) {
        AppEmpty({ title: '札记不存在', description: '可能已被删除或网络异常' })
      } else {
        DetailShell({
          title: '我的札记',
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
          this.HeroImage()
          Column()
            .width('100%')
            .height(200)
            .linearGradient({
              angle: 180,
              colors: [['rgba(92,107,115,0)', 0], ['rgba(92,107,115,0.78)', 1]]
            })
            .borderRadius({ topLeft: Theme.radius.xl, topRight: Theme.radius.xl })
          Column({ space: 4 }) {
            Text(this.item.recordDate.length > 0 ? this.item.recordDate : '生活札记')
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

        if (this.item.subtitle.length > 0 || this.item.category.length > 0) {
          Row({ space: 8 }) {
            if (this.item.subtitle.length > 0) {
              Text(`足迹 · ${this.item.subtitle}`)
                .fontSize(Theme.type.caption)
                .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
                .padding({ left: 10, right: 10, top: 4, bottom: 4 })
                .backgroundColor(Theme.colors().surfaceSubtle)
                .borderRadius(Theme.radius.pill)
            }
            if (this.item.category.length > 0) {
              Text(`心情 · ${MoodCatalog.labelOf(this.item.category)}`)
                .fontSize(Theme.type.caption)
                .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
                .padding({ left: 10, right: 10, top: 4, bottom: 4 })
                .backgroundColor(Theme.colors().surfaceSubtle)
                .borderRadius(Theme.radius.pill)
            }
          }
          .width('100%')
          .padding({ left: Theme.space.pageX, right: Theme.space.pageX })
        }

        if (this.item.tags.length > 0) {
          Row({ space: 8 }) {
            ForEach(this.item.tags, (tag: string) => {
              Text(tag)
                .fontSize(Theme.type.caption)
                .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
                .padding({ left: 10, right: 10, top: 4, bottom: 4 })
                .backgroundColor(Theme.colors().surfaceSubtle)
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

        if (this.photoKeys().length > 0) {
          Column() {
            AppCard({ title: '生活瞬间', variant: 'plain' }) {
              AlbumPhotoGrid({ photoKeys: this.photoKeys(), columns: 3 })
            }
          }
          .width('100%')
          .padding({ left: Theme.space.pageX, right: Theme.space.pageX })
        }

        Column({ space: Theme.space.s3 }) {
          AppButton({
            label: this.alreadyFavorited ? '已在美好收藏' : '加入美好收藏',
            variant: 'secondary',
            disabled: this.alreadyFavorited,
            onTap: (): void => { void this.handleFavorite() }
          })
          AppButton({
            label: '复制札记正文',
            variant: 'secondary',
            onTap: (): void => { this.handleExport() }
          })
        }
        .width('100%')
        .padding({ left: Theme.space.pageX, right: Theme.space.pageX })
      }
    }
  }
}
