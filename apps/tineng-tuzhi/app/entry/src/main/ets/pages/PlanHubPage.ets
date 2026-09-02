import { Theme } from '../components/design-system/Theme'
import { AppButton } from '../components/design-system/AppButton'
import { AppIcon } from '../components/design-system/AppIcon'
import { ChallengeCatalog, CyclePlan, GoalChallenge, PlanCatalog, PrepLine, PrepList, ProgramCatalog } from '../models/TrainingModels'
import { TrainingStore } from '../services/TrainingStore'
import { FitDataNotify } from '../services/FitDataNotify'

@Component
export struct PlanHubPage {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @StorageLink('fitDataEpoch') @Watch('onDataEpochChange') fitDataEpoch: number = 0
  @Prop @Watch('onRefreshTokenChange') refreshToken: number = 0
  @Prop bottomInset: number = 76
  onOpenWeekPlan: () => void = () => {}
  onOpenPrograms: () => void = () => {}
  onRecord: () => void = () => {}
  @State plans: CyclePlan[] = []
  @State challenges: GoalChallenge[] = []
  @State lists: PrepList[] = []
  @State listTick: number = 0
  @State toastText: string = ''
  @State vitalityPreview: string = ''

  aboutToAppear(): void {
    const days = PlanCatalog.vitalityDays()
    const bits: string[] = []
    for (let i = 0; i < 3 && i < days.length; i++) {
      bits.push(`Day${i + 1} ${days[i]}`)
    }
    this.vitalityPreview = `${bits.join(' · ')} …`
    void this.reload()
  }

  onRefreshTokenChange(): void {
    void this.reload()
  }

  onDataEpochChange(): void {
    void this.reload()
  }

  private async reload(): Promise<void> {
    await TrainingStore.ensureTemplates()
    this.plans = await TrainingStore.loadPlans()
    this.challenges = await TrainingStore.loadChallenges()
    this.lists = await this.cloneLists(await TrainingStore.loadLists())
    this.listTick++
  }

  private cloneLists(src: PrepList[]): PrepList[] {
    const out: PrepList[] = []
    for (const p of src) {
      const copy = new PrepList()
      copy.id = p.id
      copy.title = p.title
      copy.itemsText = p.itemsText
      copy.doneMask = p.doneMask
      copy.rebuildLines()
      out.push(copy)
    }
    return out
  }

  private toast(msg: string): void {
    this.toastText = msg
    setTimeout((): void => { this.toastText = '' }, 2200)
  }

  private async applyVitality(): Promise<void> {
    await TrainingStore.applyVitalityPlan()
    await this.reload()
    this.toast('已加入 7 天活力计划')
  }

  private async startCh(id: string): Promise<void> {
    await TrainingStore.startCatalogChallenge(id)
    await this.reload()
    this.toast('挑战已开始，完成条件见成长页')
  }

  private async toggleCh(id: string): Promise<void> {
    await TrainingStore.toggleChallenge(id)
    await FitDataNotify.syncStats()
    await this.reload()
    this.toast('挑战状态已更新')
  }

  private handleLineTap(listId: string, index: number): void {
    void this.toggleLine(listId, index)
  }

  private async toggleLine(listId: string, index: number): Promise<void> {
    const ok = await TrainingStore.toggleListItem(listId, index)
    if (!ok) {
      this.toast('更新失败，请重试')
      return
    }
    this.lists = await this.cloneLists(await TrainingStore.loadLists())
    this.listTick++
    this.toast('已更新清单进度')
  }

  private catalogJoined(id: string): boolean {
    for (const c of this.challenges) {
      if (c.id === id) {
        return true
      }
    }
    return false
  }

  private catalogDone(id: string): boolean {
    for (const c of this.challenges) {
      if (c.id === id && c.done) {
        return true
      }
    }
    return false
  }

  private listPct(p: PrepList): number {
    if (p.lines.length === 0) {
      return 0
    }
    let done = 0
    for (const ln of p.lines) {
      if (ln.done) {
        done++
      }
    }
    return Math.round((done * 100) / p.lines.length)
  }

  build() {
    Stack({ alignContent: Alignment.Top }) {
      Scroll() {
        Column({ space: Theme.space.s4 }) {
          Text('训练计划中心')
            .fontSize(Theme.type.title2)
            .fontWeight(FontWeight.Bold)
            .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
            .width('100%')

          Column({ space: Theme.space.s2 }) {
            Text('本周图志')
              .fontSize(Theme.type.subhead)
              .fontColor(Theme.colors().textPrimary)
              .width('100%')
            Text('给周一到周日排类型和分钟，作为本周底图。')
              .fontSize(Theme.type.bodyS)
              .fontColor(Theme.colors().textSecondary)
              .width('100%')
            AppButton({
              label: '编排本周训练',
              variant: 'primary',
              onTap: (): void => this.onOpenWeekPlan()
            })
          }
          .width('100%')
          .padding(Theme.space.cardPadding)
          .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
          .borderRadius(Theme.radius.lg)

          Column({ space: Theme.space.s2 }) {
            Text(PlanCatalog.vitalityTitle())
              .fontSize(Theme.type.subhead)
              .fontColor(Theme.colors().textPrimary)
              .width('100%')
            Text(this.vitalityPreview)
              .fontSize(Theme.type.bodyS)
              .fontColor(Theme.colors().textSecondary)
              .width('100%')
            AppButton({
              label: '套用到我的计划',
              variant: 'secondary',
              onTap: (): void => { void this.applyVitality() }
            })
          }
          .width('100%')
          .padding(Theme.space.cardPadding)
          .backgroundColor(Theme.colors().brandPrimaryContainer)
          .borderRadius(Theme.radius.lg)

          Column({ space: Theme.space.s2 }) {
            Text('结构化训练方案')
              .fontSize(Theme.type.subhead)
              .fontColor(Theme.colors().textPrimary)
              .width('100%')
            Text(`入门 4 周 · 跑步进阶 · 居家力量，共 ${ProgramCatalog.all().length} 套多周方案可加入周期计划。`)
              .fontSize(Theme.type.bodyS)
              .fontColor(Theme.colors().textSecondary)
              .width('100%')
            AppButton({
              label: '浏览训练方案库',
              variant: 'secondary',
              onTap: (): void => this.onOpenPrograms()
            })
          }
          .width('100%')
          .padding(Theme.space.cardPadding)
          .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
          .borderRadius(Theme.radius.lg)

          Text('我的周期计划')
            .fontSize(Theme.type.subhead)
            .fontColor(Theme.colors().textPrimary)
            .width('100%')
          if (this.plans.length === 0) {
            Text('还没有周期计划。可套用 7 天模板。')
              .fontSize(Theme.type.bodyS)
              .fontColor(Theme.colors().textSecondary)
              .width('100%')
          } else {
            ForEach(this.plans, (p: CyclePlan) => {
              Column({ space: 4 }) {
                Text(p.title)
                  .fontSize(Theme.type.body)
                  .fontColor(Theme.colors().textPrimary)
                Text(`${p.goalText} · ${p.periodDays} 天 · 自 ${p.startKey}`)
                  .fontSize(Theme.type.caption)
                  .fontColor(Theme.colors().textSecondary)
                if (p.note.length > 0) {
                  Text(p.note)
                    .fontSize(Theme.type.caption)
                    .fontColor(Theme.colors().textSecondary)
                    .maxLines(3)
                }
              }
              .width('100%')
              .alignItems(HorizontalAlign.Start)
              .padding(Theme.space.s3)
              .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
              .borderRadius(Theme.radius.md)
            }, (p: CyclePlan) => p.id)
          }

          Text('体能挑战馆')
            .fontSize(Theme.type.subhead)
            .fontColor(Theme.colors().textPrimary)
            .width('100%')
          ForEach(ChallengeCatalog.all(), (c: ChallengeCatalog) => {
            Column({ space: Theme.space.s2 }) {
              Text(c.title)
                .fontSize(Theme.type.body)
                .fontWeight(FontWeight.Medium)
                .fontColor(Theme.colors().textPrimary)
              Text(`${c.hint} · 徽章「${c.badge}」`)
                .fontSize(Theme.type.caption)
                .fontColor(Theme.colors().textSecondary)
              AppButton({
                label: this.catalogDone(c.id) ? '已完成' : (this.catalogJoined(c.id) ? '标记完成' : '开始挑战'),
                variant: this.catalogDone(c.id) ? 'secondary' : 'primary',
                onTap: (): void => {
                  if (this.catalogJoined(c.id)) {
                    void this.toggleCh(c.id)
                  } else {
                    void this.startCh(c.id)
                  }
                }
              })
            }
            .width('100%')
            .alignItems(HorizontalAlign.Start)
            .padding(Theme.space.cardPadding)
            .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
            .borderRadius(Theme.radius.lg)
          }, (c: ChallengeCatalog) => c.id)

          Text('今日训练清单')
            .fontSize(Theme.type.subhead)
            .fontColor(Theme.colors().textPrimary)
            .width('100%')
          ForEach(this.lists, (p: PrepList) => {
            Column({ space: Theme.space.s2 }) {
              Text(p.title)
                .fontSize(Theme.type.body)
                .fontColor(Theme.colors().textPrimary)
              Text(`完成 ${this.listPct(p)}%`)
                .fontSize(Theme.type.caption)
                .fontColor(Theme.colors().brandPrimary)
                .width('100%')
              ForEach(p.lines, (ln: PrepLine) => {
                Row({ space: Theme.space.s2 }) {
                  AppIcon({
                    name: ln.done ? 'check' : 'empty',
                    iconSize: Theme.icon.sm,
                    color: ln.done ? Theme.colors().brandPrimary : Theme.colors().textTertiary
                  })
                  Text(ln.text)
                    .fontSize(Theme.type.bodyS)
                    .fontColor(ln.done ? Theme.colors().brandPrimary : Theme.colors().textSecondary)
                    .layoutWeight(1)
                    .maxLines(2)
                }
                .width('100%')
                .constraintSize({ minHeight: 44 })
                .padding({ top: 4, bottom: 4 })
                .onClick((): void => { this.handleLineTap(ln.listId, ln.index) })
              }, (ln: PrepLine) => `${ln.listId}-${ln.index}-${ln.done ? '1' : '0'}-${this.listTick}`)
            }
            .width('100%')
            .alignItems(HorizontalAlign.Start)
            .padding(Theme.space.s3)
            .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
            .borderRadius(Theme.radius.md)
          }, (p: PrepList) => `${p.id}-${this.listTick}`)

          AppButton({
            label: '去写训练日志',
            variant: 'secondary',
            onTap: (): void => this.onRecord()
          })
          Row().height(this.bottomInset)
        }
        .width('100%')
        .padding({ left: Theme.space.pageX, right: Theme.space.pageX, top: Theme.space.pageY })
      }
      .width('100%')
      .height('100%')
      .scrollBar(BarState.Off)

      if (this.toastText.length > 0) {
        Text(this.toastText)
          .fontSize(Theme.type.bodyS)
          .fontColor('#FFFFFF')
          .padding({ left: 16, right: 16, top: 10, bottom: 10 })
          .margin({ top: 48 })
          .backgroundColor('#1A2332')
          .borderRadius(Theme.radius.pill)
      }
    }
    .width('100%')
    .height('100%')
  }
}
