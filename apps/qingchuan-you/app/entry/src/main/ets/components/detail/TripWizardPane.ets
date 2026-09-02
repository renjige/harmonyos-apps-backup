import { Theme } from '../design-system/Theme'
import { AppButton } from '../design-system/AppButton'
import { AppEmpty } from '../design-system/AppEmpty'
import { AppLoading } from '../design-system/AppLoading'
import { DetailShell } from './DetailShell'
import { DailyPlan, DestItem, PrefChip, TripCreateRequest } from '../../models/ScenicModels'
import { ScenicBizService } from '../../services/ScenicBizService'
import { ScenicDetailNav } from '../../services/ScenicDetailNav'
import { TripPlanner } from '../../services/TripPlanner'
import { AuthService } from '../../services/AuthService'

@Component
export struct TripWizardPane {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop @Watch('onTokenChange') refreshToken: number = 0
  @State step: number = 1
  @State dests: DestItem[] = []
  @State destId: string = ''
  @State destName: string = ''
  @State coverKey: string = 'hero_bg'
  @State days: number = 2
  @State preference: string = 'mixed'
  @State plans: DailyPlan[] = []
  @State loading: boolean = true
  @State toastText: string = ''
  @State query: string = ''
  onRequireAuth: () => void = () => {}
  private prefs: PrefChip[] = TripWizardPane.makePrefs()
  private dayOpts: number[] = [1, 2, 3, 4, 5, 6, 7]

  private static makePrefs(): PrefChip[] {
    const out: PrefChip[] = []
    out.push(PrefChip.of('nature', '自然风光'))
    out.push(PrefChip.of('history', '人文历史'))
    out.push(PrefChip.of('food', '休闲美食'))
    out.push(PrefChip.of('mixed', '综合'))
    return out
  }

  aboutToAppear(): void {
    void this.boot()
  }

  onTokenChange(): void {
    void this.boot()
  }

  private async boot(): Promise<void> {
    this.loading = true
    this.step = 1
    this.dests = await ScenicBizService.loadDestinations()
    const draftId = AppStorage.get<string>('tripDraftDestId') ?? ''
    if (draftId.length > 0) {
      this.destId = draftId
      this.destName = AppStorage.get<string>('tripDraftDestName') ?? ''
      this.coverKey = AppStorage.get<string>('tripDraftCover') ?? 'hero_bg'
      this.step = 2
    }
    this.loading = false
  }

  private showToast(msg: string): void {
    this.toastText = msg
    setTimeout(() => { this.toastText = '' }, 2200)
  }

  private filteredDests(): DestItem[] {
    return ScenicBizService.searchDest(this.dests, this.query)
  }

  private generate(): void {
    let dest: DestItem | undefined = undefined
    for (const d of this.dests) {
      if (d.id === this.destId) {
        dest = d
        break
      }
    }
    if (dest === undefined) {
      this.showToast('请先选择目的地')
      return
    }
    this.plans = TripPlanner.build(dest, this.days, this.preference)
    this.step = 4
  }

  private async save(): Promise<void> {
    if (!AuthService.requireAuth('save_trip')) {
      this.onRequireAuth()
      return
    }
    const req = new TripCreateRequest()
    req.title = `${this.destName} · ${this.days} 日`
    req.destId = this.destId
    req.destName = this.destName
    req.days = this.days
    req.preference = this.preference
    req.dailyPlanJson = TripPlanner.serialize(this.plans)
    req.coverKey = this.coverKey
    const ok = await ScenicBizService.createTrip(req)
    if (ok) {
      this.showToast('行程已保存')
      setTimeout(() => { ScenicDetailNav.close() }, 600)
      return
    }
    this.showToast('保存失败，请稍后重试')
  }

  build() {
    Stack({ alignContent: Alignment.Top }) {
      if (this.loading) {
        Column() {
          AppLoading({ label: '准备智能规划' })
        }
        .width('100%')
        .height('100%')
        .justifyContent(FlexAlign.Center)
      } else {
        DetailShell({ title: '智能规划', contentKey: `${this.step}`, onClose: () => ScenicDetailNav.close() }) {
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
      Text(`步骤 ${this.step} / 4`)
        .fontSize(Theme.type.caption)
        .fontColor(this.themeEpoch >= 0 ? Theme.colors().brandPrimary : Theme.colors().brandPrimary)
        .width('100%')
        .padding({ left: Theme.space.pageX })

      if (this.step === 1) {
        this.StepDest()
      } else if (this.step === 2) {
        this.StepDays()
      } else if (this.step === 3) {
        this.StepPref()
      } else {
        this.StepResult()
      }
    }
    .width('100%')
  }

  @Builder
  StepDest() {
    Column({ space: 8 }) {
      Text('选择目的地')
        .fontSize(Theme.type.subtitleM)
        .fontWeight(FontWeight.Medium)
        .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
        .width('100%')
      TextInput({ text: this.query, placeholder: '搜索目的地' })
        .onChange((v: string) => { this.query = v })
        .height(44)
        .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
        .borderRadius(Theme.radius.pill)
      ForEach(this.filteredDests(), (d: DestItem) => {
        Row() {
          Text(d.title)
            .fontSize(Theme.type.body)
            .fontColor(this.destId === d.id ? Theme.colors().brandPrimary : Theme.colors().textPrimary)
            .layoutWeight(1)
          Text(d.city)
            .fontSize(Theme.type.caption)
            .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
        }
        .width('100%')
        .padding(12)
        .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
        .borderRadius(Theme.radius.sm)
        .onClick(() => {
          this.destId = d.id
          this.destName = d.title
          this.coverKey = d.coverKey
          this.step = 2
        })
      }, (d: DestItem) => d.id)
    }
    .padding({ left: Theme.space.pageX, right: Theme.space.pageX })
  }

  @Builder
  StepDays() {
    Column({ space: 12 }) {
      Text(`游玩天数 · ${this.destName}`)
        .fontSize(Theme.type.subtitleM)
        .fontWeight(FontWeight.Medium)
        .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
        .width('100%')
      Row({ space: 8 }) {
        ForEach(this.dayOpts, (n: number) => {
          Text(`${n} 日`)
            .fontSize(Theme.type.caption)
            .fontColor(this.days === n ? Theme.colors().brandOnPrimary : Theme.colors().textPrimary)
            .padding({ left: 12, right: 12, top: 8, bottom: 8 })
            .backgroundColor(this.days === n ? Theme.colors().brandPrimary : Theme.colors().surfaceCard)
            .borderRadius(Theme.radius.pill)
            .onClick(() => { this.days = n })
        }, (n: number) => `${n}`)
      }
      .width('100%')
      AppButton({ label: '下一步', onTap: (): void => { this.step = 3 } })
    }
    .padding({ left: Theme.space.pageX, right: Theme.space.pageX })
  }

  @Builder
  StepPref() {
    Column({ space: 12 }) {
      Text('选择偏好')
        .fontSize(Theme.type.subtitleM)
        .fontWeight(FontWeight.Medium)
        .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
        .width('100%')
      ForEach(this.prefs, (p: PrefChip) => {
        Text(p.label)
          .fontSize(Theme.type.body)
          .fontColor(this.preference === p.id ? Theme.colors().brandOnPrimary : Theme.colors().textPrimary)
          .width('100%')
          .padding(14)
          .backgroundColor(this.preference === p.id ? Theme.colors().brandPrimary : Theme.colors().surfaceCard)
          .borderRadius(Theme.radius.md)
          .onClick(() => { this.preference = p.id })
      }, (p: PrefChip) => p.id)
      AppButton({ label: '生成行程建议', onTap: (): void => { this.generate() } })
    }
    .padding({ left: Theme.space.pageX, right: Theme.space.pageX })
  }

  @Builder
  StepResult() {
    Column({ space: 12 }) {
      Text('每日建议')
        .fontSize(Theme.type.subtitleM)
        .fontWeight(FontWeight.Medium)
        .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
        .width('100%')
      if (this.plans.length === 0) {
        AppEmpty({ title: '尚未生成', description: '返回上一步再试' })
      }
      ForEach(this.plans, (p: DailyPlan) => {
        Column({ space: 6 }) {
          Text(`第 ${p.day} 天`)
            .fontSize(Theme.type.subtitleS)
            .fontWeight(FontWeight.Medium)
            .fontColor(this.themeEpoch >= 0 ? Theme.colors().brandPrimary : Theme.colors().brandPrimary)
            .width('100%')
          Text(`上午  ${p.morning}`)
            .fontSize(Theme.type.footnote)
            .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
            .width('100%')
          Text(`下午  ${p.afternoon}`)
            .fontSize(Theme.type.footnote)
            .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
            .width('100%')
          Text(`晚上  ${p.evening}`)
            .fontSize(Theme.type.footnote)
            .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
            .width('100%')
        }
        .padding(14)
        .width('100%')
        .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
        .borderRadius(Theme.radius.md)
        .alignItems(HorizontalAlign.Start)
      }, (p: DailyPlan) => `${p.day}`)
      AppButton({ label: '保存行程', onTap: (): void => { void this.save() } })
    }
    .padding({ left: Theme.space.pageX, right: Theme.space.pageX, bottom: Theme.space.s6 })
  }
}
