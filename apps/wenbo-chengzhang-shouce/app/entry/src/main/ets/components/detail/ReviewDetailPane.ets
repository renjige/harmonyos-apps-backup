import { Theme } from '../design-system/Theme'
import { AppButton } from '../design-system/AppButton'
import { AppCard } from '../design-system/AppCard'
import { AppEmpty } from '../design-system/AppEmpty'
import { AppLoading } from '../design-system/AppLoading'
import { DetailShell } from './DetailShell'
import { GrowthRecordItem } from '../../models/GrowthModels'
import { GrowthBizService } from '../../services/GrowthBizService'

@Component
export struct ReviewDetailPane {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop itemId: string = ''
  @Prop @Watch('onItemIdChange') refreshToken: number = 0
  onReviewDeleted: () => void = () => {}
  onClose: () => void = () => {}
  @State item: GrowthRecordItem | undefined = undefined
  @State loading: boolean = true
  @State confirmDelete: boolean = false
  @State toastText: string = ''

  aboutToAppear(): void {
    void this.loadItem()
  }

  onItemIdChange(): void {
    void this.loadItem()
  }

  private async loadItem(): Promise<void> {
    this.loading = true
    this.item = await GrowthBizService.findReview(this.itemId)
    this.loading = false
  }

  private async doDelete(): Promise<void> {
    if (this.item === undefined) {
      return
    }
    const ok = await GrowthBizService.deleteReview(this.item.id)
    if (ok) {
      this.onReviewDeleted()
      this.onClose()
      return
    }
    this.confirmDelete = false
    this.toastText = '删除失败，请稍后重试'
    setTimeout(() => { this.toastText = '' }, 2400)
  }

  build() {
    Stack() {
      if (this.loading) {
        AppLoading({ label: '加载复盘…' })
      } else if (this.item === undefined) {
        AppEmpty({ title: '复盘不存在', description: '请返回列表重试' })
      } else {
        DetailShell({
          title: '复盘详情',
          onClose: (): void => { this.onClose() },
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
          Image($r('app.media.hero_kitchen'))
            .width('100%')
            .height(168)
            .objectFit(ImageFit.Cover)
            .borderRadius(Theme.radius.xl)
          Column()
            .width('100%')
            .height(168)
            .linearGradient({
              angle: 180,
              colors: [['rgba(15,23,42,0.08)', 0], ['rgba(15,23,42,0.72)', 1]]
            })
            .borderRadius(Theme.radius.xl)
          Text(this.item.title)
            .fontSize(Theme.type.title3)
            .fontWeight(FontWeight.Medium)
            .fontColor(Theme.colors().textOnInverse)
            .padding(Theme.space.s5)
        }
        .width('100%')
        AppCard({ title: this.item.title }) {
          Text(this.item.recordDate.length > 0 ? this.item.recordDate : this.item.createdAt)
            .fontSize(Theme.type.caption)
            .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
            .width('100%')
        }
        Text(this.item.body.length > 0 ? this.item.body : this.item.summary)
          .fontSize(Theme.type.subhead)
          .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
          .width('100%')
          .padding(Theme.space.s4)
          .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
          .borderRadius(Theme.radius.xl)
        if (this.confirmDelete) {
          Column({ space: Theme.space.s3 }) {
            Text('确认删除这条周复盘？')
              .fontSize(Theme.type.footnote)
              .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
              .width('100%')
            AppButton({
              label: '确认删除',
              variant: 'danger',
              onTap: (): void => { void this.doDelete() }
            })
            AppButton({
              label: '取消',
              variant: 'secondary',
              onTap: (): void => { this.confirmDelete = false }
            })
          }
          .width('100%')
        } else {
          AppButton({
            label: '删除复盘',
            variant: 'secondary',
            onTap: (): void => { this.confirmDelete = true }
          })
        }
      }
      .padding({ left: Theme.space.pageX, right: Theme.space.pageX })
      .width('100%')
    }
  }
}
