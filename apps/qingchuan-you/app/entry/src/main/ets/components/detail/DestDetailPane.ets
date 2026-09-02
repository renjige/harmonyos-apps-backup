import { Theme } from '../design-system/Theme'
import { AppButton } from '../design-system/AppButton'
import { AppEmpty } from '../design-system/AppEmpty'
import { AppLoading } from '../design-system/AppLoading'
import { DetailShell } from './DetailShell'
import { DestItem } from '../../models/ScenicModels'
import { ScenicBizService } from '../../services/ScenicBizService'
import { ScenicDetailNav } from '../../services/ScenicDetailNav'
import { ScenicMedia } from '../../services/ScenicMedia'
import { AuthService } from '../../services/AuthService'

@Component
export struct DestDetailPane {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop @Watch('onDestIdChange') destId: string = ''
  @Prop @Watch('onDestIdChange') refreshToken: number = 0
  @State item: DestItem | undefined = undefined
  @State loading: boolean = true
  @State favored: boolean = false
  @State toastText: string = ''
  onRequireAuth: () => void = () => {}

  aboutToAppear(): void {
    void this.reload()
  }

  onDestIdChange(): void {
    void this.reload()
  }

  private async reload(): Promise<void> {
    this.loading = true
    this.item = await ScenicBizService.findDest(this.destId)
    this.favored = await ScenicBizService.isFavored(this.destId)
    this.loading = false
  }

  private showToast(msg: string): void {
    this.toastText = msg
    setTimeout(() => {
      this.toastText = ''
    }, 2200)
  }

  private async toggleFav(): Promise<void> {
    if (!AuthService.requireAuth('add_favorite')) {
      this.onRequireAuth()
      return
    }
    if (this.item === undefined) {
      return
    }
    this.favored = await ScenicBizService.toggleFavorite('destination', this.item.id, this.item.title, this.item.coverKey)
    this.showToast(this.favored ? '已收藏' : '已取消收藏')
  }

  private planTrip(): void {
    if (this.item === undefined) {
      return
    }
    ScenicDetailNav.openTripNew(this.item.id, this.item.title, this.item.coverKey)
  }

  private current(): DestItem {
    if (this.item !== undefined) {
      return this.item
    }
    return new DestItem()
  }

  private tagsText(): string {
    if (this.item === undefined) {
      return ''
    }
    let s = ''
    for (const t of this.item.tags) {
      if (s.length > 0) {
        s += '  ·  '
      }
      s += t
    }
    return s
  }

  build() {
    Stack({ alignContent: Alignment.Top }) {
      if (this.loading) {
        Column() {
          AppLoading({ label: '打开这座风景' })
        }
        .width('100%')
        .height('100%')
        .justifyContent(FlexAlign.Center)
      } else if (this.item === undefined) {
        DetailShell({ title: '目的地', onClose: () => ScenicDetailNav.close() }) {
          AppEmpty({ title: '暂时看不见', description: '刷新后再试', actionLabel: '重试', onAction: () => { void this.reload() } })
        }
      } else {
        DetailShell({ title: this.item.title, contentKey: this.item.id, onClose: () => ScenicDetailNav.close() }) {
          this.Body()
        }
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
  Body() {
    Column({ space: Theme.space.s4 }) {
      Stack({ alignContent: Alignment.BottomStart }) {
        Image(ScenicMedia.resource(this.current().coverKey))
          .width('100%')
          .height(240)
          .objectFit(ImageFit.Cover)
        Column()
          .width('100%')
          .height(120)
          .linearGradient({
            angle: 180,
            colors: [['rgba(15,23,42,0)', 0], ['rgba(27,58,92,0.78)', 1]]
          })
        Column({ space: 4 }) {
          Text(this.current().title)
            .fontSize(Theme.type.title2)
            .fontWeight(FontWeight.Bold)
            .fontColor('#F8FAFC')
          Text(`${this.current().city} · ${this.current().categoryLabel()}`)
            .fontSize(Theme.type.body)
            .fontColor('#F8FAFC')
        }
        .padding(16)
      }
      .width('100%')
      .height(240)
      .borderRadius(Theme.radius.lg)
      .clip(true)
      .margin({ left: Theme.space.pageX, right: Theme.space.pageX })

      Column({ space: 8 }) {
        Text(`${this.current().daysLabel()} · 最佳 ${this.current().bestSeason}`)
          .fontSize(Theme.type.footnote)
          .fontColor(this.themeEpoch >= 0 ? Theme.colors().brandPrimary : Theme.colors().brandPrimary)
          .width('100%')
        Text(this.tagsText())
          .fontSize(Theme.type.caption)
          .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
          .width('100%')
      }
      .padding({ left: Theme.space.pageX, right: Theme.space.pageX })

      Column({ space: 8 }) {
        Text('导语')
          .fontSize(Theme.type.subtitleM)
          .fontWeight(FontWeight.Medium)
          .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
          .width('100%')
        Text(this.current().summary)
          .fontSize(Theme.type.body)
          .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
          .width('100%')
      }
      .padding(16)
      .margin({ left: Theme.space.pageX, right: Theme.space.pageX })
      .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
      .borderRadius(Theme.radius.md)
      .alignItems(HorizontalAlign.Start)

      Column({ space: 10 }) {
        Text('介绍')
          .fontSize(Theme.type.subtitleM)
          .fontWeight(FontWeight.Medium)
          .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
          .width('100%')
        Text(this.current().body)
          .fontSize(Theme.type.body)
          .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
          .width('100%')
        Text(`当地特色  ${this.current().spots}`)
          .fontSize(Theme.type.footnote)
          .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
          .width('100%')
        Text(`游玩贴士  ${this.current().tips}`)
          .fontSize(Theme.type.footnote)
          .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
          .width('100%')
      }
      .padding({ left: Theme.space.pageX, right: Theme.space.pageX })
      .alignItems(HorizontalAlign.Start)

      Column({ space: 10 }) {
        AppButton({
          label: '智能规划行程',
          onTap: (): void => { this.planTrip() }
        })
        AppButton({
          label: this.favored ? '取消收藏' : '收藏目的地',
          variant: 'secondary',
          onTap: (): void => { void this.toggleFav() }
        })
      }
      .padding({ left: Theme.space.pageX, right: Theme.space.pageX, bottom: Theme.space.s6 })
    }
    .width('100%')
  }
}
