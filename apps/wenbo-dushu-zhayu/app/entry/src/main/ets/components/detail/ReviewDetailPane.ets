import { Theme } from '../design-system/Theme'
import { AppCard } from '../design-system/AppCard'
import { AppButton } from '../design-system/AppButton'
import { AppLoading } from '../design-system/AppLoading'
import { DetailShell } from './DetailShell'
import { DetailMissingPane } from './DetailMissingPane'
import { ReviewItem } from '../../models/ReadingModels'
import { ReadingBizService } from '../../services/ReadingBizService'
import { ReadingMedia } from '../../services/ReadingMedia'
import { ReadingDetailNav } from '../../services/ReadingDetailNav'

@Component
export struct ReviewDetailPane {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop itemId: string = ''
  @Prop @Watch('onItemIdChange') refreshToken: number = 0
  onDeleted: () => void = () => {}
  @State item: ReviewItem | undefined = undefined
  @State loading: boolean = true

  aboutToAppear(): void {
    void this.loadItem()
  }

  onItemIdChange(): void {
    void this.loadItem()
  }

  private async loadItem(): Promise<void> {
    this.loading = true
    this.item = await ReadingBizService.findReview(this.itemId)
    this.loading = false
  }

  private async handleDelete(): Promise<void> {
    if (this.item === undefined) {
      ReadingDetailNav.close()
      return
    }
    const ok = await ReadingBizService.deleteReview(this.item.id)
    if (ok) {
      this.onDeleted()
      ReadingDetailNav.close()
    }
  }

  build() {
    if (this.loading) {
      AppLoading({ label: '加载书评…' })
    } else if (this.item === undefined) {
      DetailMissingPane({
        title: '书评',
        emptyTitle: '书评不存在',
        emptyDescription: '可能已被删除，请返回继续使用'
      })
    } else {
      DetailShell({
        title: '书评记录',
        onClose: (): void => { ReadingDetailNav.close() },
        body: (): void => { this.DetailBody() }
      })
    }
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
            Text(`${this.item.rating} 星评价`)
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
          AppCard({ title: '阅读体验', variant: 'plain' }) {
            Text(this.item.body.length > 0 ? this.item.body : this.item.summary)
              .fontSize(Theme.type.body)
              .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
              .lineHeight(24)
              .width('100%')
          }
        }
        .padding({ left: Theme.space.pageX, right: Theme.space.pageX })
        .width('100%')
        AppButton({
          label: '删除书评',
          variant: 'danger',
          onTap: (): void => { void this.handleDelete() }
        })
          .padding({ left: Theme.space.pageX, right: Theme.space.pageX })
      }
    }
  }
}
