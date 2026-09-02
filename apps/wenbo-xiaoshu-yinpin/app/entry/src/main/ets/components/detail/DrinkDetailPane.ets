import { Theme } from '../design-system/Theme'
import { AppButton } from '../design-system/AppButton'
import { AppEmpty } from '../design-system/AppEmpty'
import { AppLoading } from '../design-system/AppLoading'
import { DetailShell } from './DetailShell'
import { DrinkItem } from '../../models/DrinkModels'
import { DrinkBizService } from '../../services/DrinkBizService'
import { DrinkDetailNav } from '../../services/DrinkDetailNav'
import { DrinkMedia } from '../../services/DrinkMedia'
import { AuthService } from '../../services/AuthService'
import { HistoryStore } from '../../services/HistoryStore'

@Component
export struct DrinkDetailPane {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop @Watch('onDrinkIdChange') drinkId: string = ''
  @Prop @Watch('onDrinkIdChange') refreshToken: number = 0
  @State item: DrinkItem | undefined = undefined
  @State loading: boolean = true
  @State favored: boolean = false
  @State toastText: string = ''
  onRequireAuth: () => void = () => {}

  aboutToAppear(): void {
    void this.reload()
  }

  onDrinkIdChange(): void {
    void this.reload()
  }

  private async reload(): Promise<void> {
    this.loading = true
    this.item = await DrinkBizService.findDrink(this.drinkId)
    this.favored = await DrinkBizService.isFavored(this.drinkId)
    this.loading = false
    if (this.item !== undefined) {
      await HistoryStore.push(this.item.id)
    }
  }

  private showToast(msg: string): void {
    this.toastText = msg
    setTimeout(() => {
      this.toastText = ''
    }, 2200)
  }

  private current(): DrinkItem {
    if (this.item !== undefined) {
      return this.item
    }
    return new DrinkItem()
  }

  private async toggleFav(): Promise<void> {
    if (!AuthService.requireAuth('add_favorite')) {
      this.onRequireAuth()
      return
    }
    if (this.item === undefined) {
      return
    }
    this.favored = await DrinkBizService.toggleFavorite(this.item)
    this.showToast(this.favored ? '已收藏这杯' : '已取消收藏')
  }

  private async logTry(): Promise<void> {
    if (!AuthService.requireAuth('log_try')) {
      this.onRequireAuth()
      return
    }
    if (this.item === undefined) {
      return
    }
    const ok = await DrinkBizService.createTry(this.item, '')
    this.showToast(ok ? '已记下今天的试做' : '记下失败，请稍后重试')
  }

  build() {
    Stack({ alignContent: Alignment.Top }) {
      if (this.loading) {
        AppLoading({ label: '正在打开这杯消暑饮' })
      } else if (this.item === undefined) {
        Column() {
          AppEmpty({ title: '没有找到这杯', description: '返回饮品库再选一杯', actionLabel: '返回', onAction: () => DrinkDetailNav.close() })
        }
        .width('100%')
        .height('100%')
      } else {
        DetailShell({
          title: this.current().title,
          contentKey: this.drinkId,
          onClose: () => DrinkDetailNav.close()
        }) {
          this.Body()
        }
      }

      if (this.toastText.length > 0) {
        Text(this.toastText)
          .fontSize(Theme.type.subhead)
          .fontColor('#FFFFFF')
          .padding({ left: 16, right: 16, top: 10, bottom: 10 })
          .backgroundColor('#CC1A2332')
          .borderRadius(Theme.radius.pill)
          .margin({ top: 56 })
      }
    }
    .width('100%')
    .height('100%')
  }

  @Builder
  Body() {
    Column({ space: Theme.space.s4 }) {
      Stack({ alignContent: Alignment.BottomStart }) {
        Image(DrinkMedia.resource(this.current().coverKey))
          .width('100%')
          .height(240)
          .objectFit(ImageFit.Cover)
        Column()
          .width('100%')
          .height(96)
          .linearGradient({ direction: GradientDirection.Bottom, colors: [['#00000000', 0], ['#CC0B3A48', 1]] })
        Text(this.current().title)
          .fontSize(Theme.type.title2)
          .fontWeight(FontWeight.Bold)
          .fontColor('#FFFFFF')
          .padding({ left: Theme.space.pageX, right: Theme.space.pageX, bottom: Theme.space.s4 })
          .width('100%')
      }
      .width('100%')
      .clip(true)

      Column({ space: 6 }) {
        Text(this.current().metaLine())
          .fontSize(Theme.type.subhead)
          .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
        Text(`${this.current().slotLabel()} · 体感 ${this.current().tempMin}–${this.current().tempMax}℃ · ${this.current().iceLevel} · ${this.current().sweetness}`)
          .fontSize(Theme.type.caption)
          .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
      }
      .padding({ left: Theme.space.pageX, right: Theme.space.pageX })
      .alignItems(HorizontalAlign.Start)
      .width('100%')

      Column({ space: 8 }) {
        Text('这杯适合')
          .fontSize(Theme.type.subtitleS)
          .fontWeight(FontWeight.Medium)
          .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
        Text(this.current().summary)
          .fontSize(Theme.type.body)
          .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
        Text(this.current().body)
          .fontSize(Theme.type.subhead)
          .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
      }
      .padding(Theme.space.s4)
      .margin({ left: Theme.space.pageX, right: Theme.space.pageX })
      .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
      .borderRadius(Theme.radius.md)
      .alignItems(HorizontalAlign.Start)
      .width('100%')

      this.LineList('食材', this.current().ingredients)
      this.StepList()

      Column({ space: 8 }) {
        Text('功效说明')
          .fontSize(Theme.type.subtitleS)
          .fontWeight(FontWeight.Medium)
          .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
        Text(this.current().effect)
          .fontSize(Theme.type.body)
          .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
      }
      .padding(Theme.space.s4)
      .margin({ left: Theme.space.pageX, right: Theme.space.pageX })
      .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
      .borderRadius(Theme.radius.md)
      .alignItems(HorizontalAlign.Start)
      .width('100%')

      Column({ space: Theme.space.s3 }) {
        AppButton({
          label: this.favored ? '取消收藏' : '收藏这杯',
          onTap: (): void => { void this.toggleFav() }
        })
        AppButton({
          label: '记下今天的试做',
          variant: 'secondary',
          onTap: (): void => { void this.logTry() }
        })
      }
      .padding({ left: Theme.space.pageX, right: Theme.space.pageX, bottom: Theme.space.s6 })
      .width('100%')
    }
    .width('100%')
  }

  @Builder
  LineList(title: string, lines: string[]) {
    Column({ space: 8 }) {
      Text(title)
        .fontSize(Theme.type.subtitleS)
        .fontWeight(FontWeight.Medium)
        .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
        .width('100%')
      ForEach(lines, (line: string, idx: number) => {
        Text(`· ${line}`)
          .fontSize(Theme.type.body)
          .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
          .width('100%')
      }, (line: string, idx: number) => `${title}-${idx}`)
    }
    .padding(Theme.space.s4)
    .margin({ left: Theme.space.pageX, right: Theme.space.pageX })
    .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
    .borderRadius(Theme.radius.md)
    .alignItems(HorizontalAlign.Start)
    .width('100%')
  }

  @Builder
  StepList() {
    Column({ space: 8 }) {
      Text('制作步骤')
        .fontSize(Theme.type.subtitleS)
        .fontWeight(FontWeight.Medium)
        .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
        .width('100%')
      ForEach(this.current().steps, (line: string, idx: number) => {
        Text(`${idx + 1}. ${line}`)
          .fontSize(Theme.type.body)
          .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
          .width('100%')
      }, (line: string, idx: number) => `st-${idx}`)
    }
    .padding(Theme.space.s4)
    .margin({ left: Theme.space.pageX, right: Theme.space.pageX })
    .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
    .borderRadius(Theme.radius.md)
    .alignItems(HorizontalAlign.Start)
    .width('100%')
  }
}
