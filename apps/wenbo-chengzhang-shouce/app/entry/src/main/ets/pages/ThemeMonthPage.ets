import { Theme } from '../components/design-system/Theme'
import { AppHeader } from '../components/design-system/AppHeader'
import { AppButton } from '../components/design-system/AppButton'
import { AppLoading } from '../components/design-system/AppLoading'
import { CreateRecordRequest, GrowthRecordItem, StatsData } from '../models/GrowthModels'
import { MonthThemeUtil } from '../models/StuckWorkshop'
import { GrowthBizService } from '../services/GrowthBizService'
import { AuthService } from '../services/AuthService'

@Component
export struct ThemeMonthPage {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @StorageLink('currentUsername') currentUsername: string = ''
  onClose: () => void = () => {}
  onRequireAuth: () => void = () => {}
  onSaved: () => void = () => {}
  @State theme: string = ''
  @State themeOptions: string[] = MonthThemeUtil.options()
  @State records: GrowthRecordItem[] = []
  @State stats: StatsData = new StatsData()
  @State monthCount: number = 0
  @State loading: boolean = true
  @State submitting: boolean = false
  @State toastText: string = ''
  @State errorText: string = ''

  aboutToAppear(): void {
    void this.reload()
  }

  private async reload(): Promise<void> {
    this.loading = true
    if (AuthService.isLoggedIn()) {
      this.records = await GrowthBizService.loadRecords(this.currentUsername)
      this.stats = await GrowthBizService.loadStats(this.currentUsername)
      this.theme = MonthThemeUtil.findTheme(this.records)
      this.monthCount = this.countThisMonth(this.records)
    } else {
      this.records = []
      this.stats = new StatsData()
      this.theme = ''
      this.monthCount = 0
    }
    this.loading = false
  }

  private countThisMonth(records: GrowthRecordItem[]): number {
    const key = MonthThemeUtil.monthKey()
    let n = 0
    for (const r of records) {
      if (r.recordDate.indexOf(key) === 0 && r.title.indexOf('月度主题') < 0) {
        n += 1
      }
    }
    return n
  }

  private reportBody(): string {
    const themeName = this.theme.length > 0 ? this.theme : '尚未选定'
    return `本月主题：${themeName}\n本月记录：${this.monthCount} 条\n目标总数：${this.stats.goalCount}\n已完成目标：${this.stats.completedGoals}\n连续记录：${this.stats.streakDays} 天\n\n下月建议：只保留一件最重要的事，其余放进「卡住工坊」拆成最小步骤。`
  }

  private async saveTheme(): Promise<void> {
    if (!AuthService.requireAuth('create_record')) {
      this.onRequireAuth()
      return
    }
    if (this.theme.length === 0) {
      this.errorText = '请先选择本月主题'
      return
    }
    this.submitting = true
    this.errorText = ''
    const req = new CreateRecordRequest()
    req.title = MonthThemeUtil.themeTitle()
    req.body = `本月只经营「${this.theme}」。新记录请带上该主题标签。`
    req.summary = this.theme
    req.coverKey = 'hero_spatial'
    const tags: string[] = []
    tags.push('月度主题')
    tags.push(this.theme)
    req.tags = tags
    req.userId = this.currentUsername
    const created = await GrowthBizService.createRecord(req)
    this.submitting = false
    if (created !== undefined) {
      this.onSaved()
      this.toastText = `本月主题已设为「${this.theme}」`
      setTimeout(() => { this.toastText = '' }, 2000)
      await this.reload()
    } else {
      this.errorText = '保存失败，请稍后重试'
    }
  }

  private async saveReport(): Promise<void> {
    if (!AuthService.requireAuth('create_record')) {
      this.onRequireAuth()
      return
    }
    this.submitting = true
    const req = new CreateRecordRequest()
    req.title = MonthThemeUtil.reportTitle()
    req.body = this.reportBody()
    req.summary = this.theme.length > 0 ? this.theme : '本月预览'
    req.coverKey = 'hero_spatial'
    const tags: string[] = []
    tags.push('月报')
    req.tags = tags
    req.userId = this.currentUsername
    const created = await GrowthBizService.createRecord(req)
    this.submitting = false
    if (created !== undefined) {
      this.onSaved()
      this.toastText = '月报已写入成长记录'
      setTimeout(() => {
        this.toastText = ''
        this.onClose()
      }, 800)
    } else {
      this.errorText = '保存月报失败'
    }
  }

  build() {
    Stack() {
      Column() {
        AppHeader({ title: '月度主题月', subtitle: `经营 ${MonthThemeUtil.monthKey()} 这一个月` })
        if (this.loading) {
          AppLoading({ label: '加载本月…' }).layoutWeight(1)
        } else {
          Scroll() {
            Column({ space: Theme.space.s4 }) {
              Image($r('app.media.hero_spatial'))
                .width('100%')
                .height(132)
                .objectFit(ImageFit.Cover)
                .borderRadius(Theme.radius.xl)
              Text('选定主题后，本月新记录建议带上同一标签。可随时保存一份规则模板月报（非 AI）。')
                .fontSize(Theme.type.footnote)
                .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
                .width('100%')
              Flex({ wrap: FlexWrap.Wrap }) {
                ForEach(this.themeOptions, (opt: string) => {
                  Text(opt)
                    .fontSize(Theme.type.subhead)
                    .fontColor(this.theme === opt ? Theme.colors().brandOnPrimary : Theme.colors().brandPrimary)
                    .padding({ left: 16, right: 16, top: 10, bottom: 10 })
                    .margin({ right: 8, bottom: 8 })
                    .backgroundColor(this.theme === opt ?
                      Theme.colors().brandPrimary : Theme.colors().brandPrimaryContainer)
                    .borderRadius(Theme.radius.pill)
                    .onClick((): void => { this.theme = opt })
                }, (opt: string) => opt)
              }
              .width('100%')
              AppButton({
                label: this.submitting ? '保存中…' : '保存本月主题',
                onTap: (): void => { void this.saveTheme() }
              })
              Text(this.reportBody())
                .fontSize(Theme.type.subhead)
                .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
                .width('100%')
                .padding(Theme.space.s4)
                .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
                .borderRadius(Theme.radius.xl)
              if (this.errorText.length > 0) {
                Text(this.errorText)
                  .fontSize(Theme.type.footnote)
                  .fontColor(Theme.colors().danger)
                  .width('100%')
              }
              AppButton({
                label: '保存本月预览月报',
                variant: 'secondary',
                onTap: (): void => { void this.saveReport() }
              })
              AppButton({
                label: '返回',
                variant: 'ghost',
                onTap: (): void => { this.onClose() }
              })
            }
            .padding({
              left: Theme.space.pageX,
              right: Theme.space.pageX,
              bottom: Theme.space.s10
            })
            .width('100%')
          }
          .layoutWeight(1)
          .scrollBar(BarState.Off)
        }
      }
      .width('100%')
      .height('100%')
      .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfacePage : Theme.colors().surfacePage)

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
        .padding({ top: Theme.space.s8 })
        .alignItems(HorizontalAlign.Center)
        .zIndex(30)
      }
    }
    .width('100%')
    .height('100%')
  }
}
