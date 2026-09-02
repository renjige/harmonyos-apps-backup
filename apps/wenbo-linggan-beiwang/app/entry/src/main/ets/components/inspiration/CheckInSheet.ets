import { Theme } from '../design-system/Theme'
import { AppButton } from '../design-system/AppButton'
import { AppIcon } from '../design-system/AppIcon'
import { GrowthStore } from '../../services/GrowthStore'
import { GrowthService } from '../../services/GrowthService'
import { AuthService } from '../../services/AuthService'
import { InspirationBizService } from '../../services/InspirationBizService'
import { AchievementService } from '../../services/AchievementService'

@Component
export struct CheckInSheet {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @StorageLink('currentUsername') currentUsername: string = ''
  onClose: () => void = () => {}
  onSaved: () => void = () => {}
  onRequireAuth: () => void = () => {}
  @State note: string = ''
  @State saving: boolean = false
  @State formError: string = ''
  @State already: boolean = false

  aboutToAppear(): void {
    void this.prefill()
  }

  private async prefill(): Promise<void> {
    if (!AuthService.isLoggedIn()) {
      return
    }
    const data = await GrowthStore.load(this.currentUsername)
    const today = GrowthService.todayIso()
    this.already = GrowthService.hasCheckIn(data, today)
    for (const row of data.checkIns) {
      if (row.date === today) {
        this.note = row.note
      }
    }
  }

  private async submit(): Promise<void> {
    if (!AuthService.requireAuth('create_inspiration')) {
      this.onRequireAuth()
      return
    }
    this.saving = true
    this.formError = ''
    const data = await GrowthStore.load(this.currentUsername)
    const today = GrowthService.todayIso()
    GrowthService.addCheckIn(data, today, this.note.trim())
    GrowthService.pushActivity(data, 'checkin', this.note.trim().length > 0 ? this.note.trim() : '今日捕捉打卡', 'checkin', today)
    const ins = await InspirationBizService.loadInspirations(this.currentUsername)
    const plans = await InspirationBizService.loadCreativePlans(this.currentUsername)
    const fav = await InspirationBizService.loadFavorites(this.currentUsername)
    AchievementService.evaluate(data, ins, plans, fav)
    await GrowthService.persist(this.currentUsername, data)
    this.saving = false
    this.onSaved()
    this.onClose()
  }

  build() {
    Column() {
      Row({ space: Theme.space.s2 }) {
        Column() {
          AppIcon({ name: 'close', iconSize: Theme.icon.md })
        }
        .width(44)
        .height(44)
        .justifyContent(FlexAlign.Center)
        .onClick((): void => { this.onClose() })
        Text('今日捕捉打卡')
          .fontSize(Theme.type.title3)
          .fontWeight(FontWeight.Medium)
          .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
          .layoutWeight(1)
      }
      .width('100%')
      .padding({ left: Theme.space.pageX - 8, right: Theme.space.pageX, top: Theme.space.s2 })

      Text('来不及写成完整备忘时，用一句话记下今天看见的东西。打卡会记入连续天数、本周统计和成就墙。')
        .fontSize(Theme.type.footnote)
        .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
        .width('100%')
        .padding({ left: Theme.space.pageX, right: Theme.space.pageX, bottom: Theme.space.s3 })

      if (this.formError.length > 0) {
        Text(this.formError)
          .fontSize(Theme.type.footnote)
          .fontColor(Theme.colors().danger)
          .padding({ left: Theme.space.pageX, right: Theme.space.pageX })
      }

      TextArea({
        text: this.note,
        placeholder: '例如：傍晚橱窗的暖黄和冷白撞在一起'
      })
        .width('100%')
        .height(140)
        .margin({ left: Theme.space.pageX, right: Theme.space.pageX })
        .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
        .borderRadius(Theme.radius.sm)
        .onChange((v: string) => { this.note = v })

      Column() {
        AppButton({
          label: this.saving ? '保存中…' : (this.already ? '更新今日打卡' : '完成打卡'),
          disabled: this.saving,
          onTap: (): void => { void this.submit() }
        })
      }
      .width('100%')
      .padding(Theme.space.pageX)
      .onClick((): void => {
        if (!this.saving) {
          void this.submit()
        }
      })
    }
    .width('100%')
    .height('100%')
    .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfacePage : Theme.colors().surfacePage)
  }
}
