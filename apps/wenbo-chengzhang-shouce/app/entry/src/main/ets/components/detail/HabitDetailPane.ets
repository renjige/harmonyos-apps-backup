import { Theme } from '../design-system/Theme'
import { AppButton } from '../design-system/AppButton'
import { AppCard } from '../design-system/AppCard'
import { AppEmpty } from '../design-system/AppEmpty'
import { AppLoading } from '../design-system/AppLoading'
import { DetailShell } from './DetailShell'
import { GrowthRecordItem, CheckinHabitRequest } from '../../models/GrowthModels'
import { GrowthBizService } from '../../services/GrowthBizService'
import { AuthService } from '../../services/AuthService'

@Component
export struct HabitDetailPane {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop itemId: string = ''
  @Prop @Watch('onItemIdChange') refreshToken: number = 0
  onRequireAuth: () => void = () => {}
  onHabitUpdated: () => void = () => {}
  onClose: () => void = () => {}
  @State item: GrowthRecordItem | undefined = undefined
  @State loading: boolean = true
  @State updating: boolean = false
  @State confirmDelete: boolean = false
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
    this.item = await GrowthBizService.findHabit(this.itemId)
    this.loading = false
  }

  private dateList(): string[] {
    if (this.item === undefined || this.item.cardsJson.length === 0) {
      return []
    }
    return this.item.cardsJson.split(',')
  }

  private async doCheckin(): Promise<void> {
    if (!AuthService.requireAuth('checkin_habit')) {
      this.onRequireAuth()
      return
    }
    if (this.item === undefined) {
      return
    }
    this.updating = true
    const req = new CheckinHabitRequest()
    const updated = await GrowthBizService.checkinHabit(this.item.id, req)
    this.updating = false
    if (updated !== undefined) {
      this.item = updated
      this.onHabitUpdated()
      this.showToast('今日已打卡')
    } else {
      this.showToast(GrowthBizService.lastError.length > 0 ? GrowthBizService.lastError : '打卡失败')
    }
  }

  private async doDelete(): Promise<void> {
    if (this.item === undefined) {
      return
    }
    const ok = await GrowthBizService.deleteHabit(this.item.id)
    if (ok) {
      this.onHabitUpdated()
      this.onClose()
      return
    }
    this.confirmDelete = false
    this.showToast('删除失败，请稍后重试')
  }

  build() {
    Stack() {
      if (this.loading) {
        AppLoading({ label: '加载习惯…' })
      } else if (this.item === undefined) {
        AppEmpty({ title: '习惯不存在', description: '请返回列表重试' })
      } else {
        DetailShell({
          title: '习惯详情',
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
          Image($r('app.media.hero_rain_walk'))
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
          Text(this.item.category.length > 0 ? this.item.category : '日常习惯')
            .fontSize(Theme.type.caption)
            .fontColor(this.themeEpoch >= 0 ? Theme.colors().brandPrimary : Theme.colors().brandPrimary)
            .width('100%')
          Text(`连续打卡 ${this.item.progress} 天`)
            .fontSize(Theme.type.title3)
            .fontWeight(FontWeight.Medium)
            .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
            .margin({ top: 8 })
            .width('100%')
          Text(this.item.summary.length > 0 ? this.item.summary : '坚持每天完成一次即可')
            .fontSize(Theme.type.footnote)
            .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
            .margin({ top: 6 })
            .width('100%')
        }
        if (this.dateList().length > 0) {
          Column({ space: Theme.space.s2 }) {
            Text('打卡日期')
              .fontSize(Theme.type.subhead)
              .fontWeight(FontWeight.Medium)
              .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
              .width('100%')
            ForEach(this.dateList().slice(0, 14), (d: string) => {
              Text(d)
                .fontSize(Theme.type.caption)
                .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
                .width('100%')
            }, (d: string) => d)
          }
          .width('100%')
          .padding(Theme.space.s4)
          .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
          .borderRadius(Theme.radius.xl)
        }
        AppButton({
          label: this.updating ? '打卡中…' : '今日打卡',
          onTap: (): void => { void this.doCheckin() }
        })
        if (this.confirmDelete) {
          Column({ space: Theme.space.s3 }) {
            Text('确认删除该习惯？打卡记录将一并清除。')
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
            label: '删除习惯',
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
