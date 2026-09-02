import { Theme } from '../components/design-system/Theme'
import { AppButton } from '../components/design-system/AppButton'
import { AppIcon } from '../components/design-system/AppIcon'
import { ChallengeBar, MomentCard } from '../components/sport/SportCards'
import { ChecklistRow } from '../components/sport/ChecklistRow'
import { StarRow, StatusBadge } from '../components/sport/SportVisual'
import { SportRecord, SportTypeOption } from '../models/SportRecord'
import { ChecklistItem, ResultOption, WatchChecklist } from '../models/SportExtra'
import { CollectItem, WatchStatus } from '../models/CollectModels'
import { RecordStore } from '../services/RecordStore'
import { CollectStore } from '../services/CollectStore'
import { CollectEditPage } from './CollectEditPage'
import { RecordEditPage } from './RecordEditPage'
import { RecapQuizPage } from './RecapQuizPage'
import { RecapTimelinePage } from './RecapTimelinePage'
import { MatchReportPage } from './MatchReportPage'

@Component
export struct MatchWorkbenchPage {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop seedId: string = ''
  @State record: SportRecord = new SportRecord()
  @State checklist: ChecklistItem[] = WatchChecklist.defaults()
  @State linked: CollectItem[] = []
  @State mvpInput: string = ''
  @State predictionInput: string = ''
  @State toastText: string = ''
  @State showEdit: boolean = false
  @State showRecap: boolean = false
  @State showTimeline: boolean = false
  @State showMoment: boolean = false
  @State showReport: boolean = false
  @State checklistTick: number = 0
  onClose: () => void = () => {}
  onSaved: () => void = () => {}

  aboutToAppear(): void {
    void this.reload()
  }

  private async reload(): Promise<void> {
    const found = await RecordStore.findById(this.seedId)
    if (found === undefined) {
      return
    }
    this.record = found
    this.checklist = WatchChecklist.unpack(found.checklistPacked)
    this.mvpInput = found.mvpName
    this.predictionInput = found.prediction
    this.linked = await CollectStore.loadByMatchId(found.id)
  }

  private showToast(msg: string): void {
    this.toastText = msg
    setTimeout((): void => { this.toastText = '' }, 2400)
  }

  private async persistChecklistOnly(): Promise<void> {
    this.record.checklistPacked = WatchChecklist.pack(this.checklist)
    await RecordStore.saveRecord(this.record)
  }

  private async persistRecord(): Promise<void> {
    this.record.mvpName = this.mvpInput.trim()
    this.record.prediction = this.predictionInput.trim()
    this.record.checklistPacked = WatchChecklist.pack(this.checklist)
    await RecordStore.saveRecord(this.record)
    this.onSaved()
  }

  private checklistDoneCount(): number {
    let done = 0
    for (const it of this.checklist) {
      if (it.done) {
        done++
      }
    }
    return done
  }

  private setCheckDone(id: string, done: boolean): void {
    const next: ChecklistItem[] = []
    let changed = false
    for (const it of this.checklist) {
      const copy = new ChecklistItem()
      copy.id = it.id
      copy.label = it.label
      if (it.id === id) {
        copy.done = done
        changed = it.done !== done
      } else {
        copy.done = it.done
      }
      next.push(copy)
    }
    if (!changed) {
      return
    }
    this.checklist = next
    this.checklistTick++
    this.showToast(done ? '✓ 已勾选' : '已取消勾选')
    void this.persistChecklistOnly()
  }

  private async togglePin(): Promise<void> {
    this.record.pinned = !this.record.pinned
    await this.persistRecord()
    this.showToast(this.record.pinned ? '已置顶到首页' : '已取消置顶')
  }

  private async markWatched(): Promise<void> {
    this.record.status = 'watched'
    await this.persistRecord()
    this.showToast('已标记为已看')
  }

  build() {
    Stack() {
      Column() {
        Row() {
          Row() {
            AppIcon({ name: 'close', iconSize: Theme.icon.lg, color: Theme.colors().textPrimary })
          }
          .width(44)
          .height(44)
          .justifyContent(FlexAlign.Center)
          .onClick((): void => { this.onClose() })
          Blank()
          Text('比赛工作台')
            .fontSize(Theme.type.subhead)
            .fontWeight(FontWeight.Medium)
            .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
          Blank()
          Text(this.record.pinned ? '取消置顶' : '置顶')
            .fontSize(Theme.type.caption)
            .fontColor(Theme.colors().brandPrimary)
            .onClick((): void => { void this.togglePin() })
        }
        .width('100%')
        .padding(Theme.space.pageX)

        Scroll() {
          Column({ space: Theme.space.s4 }) {
            Stack({ alignContent: Alignment.BottomStart }) {
              Image($r('app.media.hero_sport_track'))
                .width('100%')
                .height(140)
                .objectFit(ImageFit.Cover)
                .borderRadius(Theme.radius.xl)
              Column() {
                Blank()
                Column({ space: 6 }) {
                  Row({ space: Theme.space.s2 }) {
                    StatusBadge({
                      label: WatchStatus.label(this.record.status),
                      tone: this.record.status
                    })
                    if (this.record.rating > 0) {
                      StarRow({ rating: this.record.rating })
                    }
                  }
                  Text(this.record.title.length > 0 ? this.record.title : '未命名赛事')
                    .fontSize(Theme.type.title3)
                    .fontWeight(FontWeight.Bold)
                    .fontColor('#FFFFFF')
                  Text(`${SportTypeOption.emojiOf(this.record.sportType)} ${this.record.date} · ${this.record.homeTeam} vs ${this.record.opponent}`)
                    .fontSize(Theme.type.caption)
                    .fontColor('#FFFFFF')
                }
                .width('100%')
                .alignItems(HorizontalAlign.Start)
                .padding(Theme.space.s4)
                .linearGradient({
                  angle: 180,
                  colors: [['rgba(0,0,0,0)', 0], ['rgba(10,37,64,0.92)', 1]]
                })
              }
              .width('100%')
              .height('100%')
            }
            .width('100%')
            .height(140)

            Column({ space: Theme.space.s3 }) {
              Row() {
                Text('观赛准备清单')
                  .fontSize(Theme.type.subhead)
                  .fontWeight(FontWeight.Medium)
                  .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
                Blank()
                Text(`${this.checklistDoneCount()}/${this.checklist.length} 已完成`)
                  .fontSize(Theme.type.bodyS)
                  .fontWeight(FontWeight.Medium)
                  .fontColor(Theme.colors().success)
              }
              .width('100%')
              ChallengeBar({
                label: '清单完成度',
                current: this.checklistDoneCount(),
                target: this.checklist.length
              })
              ForEach(this.checklist, (it: ChecklistItem) => {
                ChecklistRow({
                  itemId: it.id,
                  label: it.label,
                  done: it.done,
                  onToggle: (id: string, nextDone: boolean): void => { this.setCheckDone(id, nextDone) }
                })
              }, (it: ChecklistItem) => `${it.id}-${it.done ? '1' : '0'}-${this.checklistTick}`)
            }
            .width('100%')
            .padding(Theme.space.s4)
            .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
            .borderRadius(Theme.radius.lg)

            Column({ space: Theme.space.s3 }) {
              Text('赛前预测 · 赛后对照')
                .fontSize(Theme.type.subhead)
                .fontWeight(FontWeight.Medium)
                .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
              TextInput({ text: this.predictionInput, placeholder: '赛前预测（例如：主队小胜）' })
                .onChange((v: string) => { this.predictionInput = v })
                .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceSubtle : Theme.colors().surfaceSubtle)
                .borderRadius(Theme.radius.md)
                .padding(Theme.space.s3)
              if (ResultOption.labelOf(this.record.result).length > 0) {
                Text(`实际结果：${ResultOption.labelOf(this.record.result)}${this.record.score.length > 0 ? ` · ${this.record.score}` : ''}`)
                  .fontSize(Theme.type.bodyS)
                  .fontColor(Theme.colors().brandPrimary)
              }
              AppButton({
                label: '保存预测',
                variant: 'secondary',
                onTap: (): void => { void this.persistRecord(); this.showToast('预测已保存') }
              })
            }
            .width('100%')
            .padding(Theme.space.s4)
            .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
            .borderRadius(Theme.radius.lg)
            .alignItems(HorizontalAlign.Start)

            Column({ space: Theme.space.s3 }) {
              Text('本场 MVP')
                .fontSize(Theme.type.subhead)
                .fontWeight(FontWeight.Medium)
                .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
              TextInput({ text: this.mvpInput, placeholder: '写下你认为的本场最佳' })
                .onChange((v: string) => { this.mvpInput = v })
                .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceSubtle : Theme.colors().surfaceSubtle)
                .borderRadius(Theme.radius.md)
                .padding(Theme.space.s3)
              AppButton({
                label: '保存 MVP',
                variant: 'secondary',
                onTap: (): void => { void this.persistRecord(); this.showToast('MVP 已保存') }
              })
            }
            .width('100%')
            .padding(Theme.space.s4)
            .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
            .borderRadius(Theme.radius.lg)
            .alignItems(HorizontalAlign.Start)

            Column({ space: Theme.space.s3 }) {
              Text('多维评价')
                .fontSize(Theme.type.subhead)
                .fontWeight(FontWeight.Medium)
                .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
              Row({ space: Theme.space.s4 }) {
                Text(`质量 ${this.record.rateQuality > 0 ? this.record.rateQuality : '-'}/5`)
                  .fontSize(Theme.type.bodyS)
                  .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
                Text(`强度 ${this.record.rateIntensity > 0 ? this.record.rateIntensity : '-'}/5`)
                  .fontSize(Theme.type.bodyS)
                  .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
                Text(`氛围 ${this.record.rateAtmosphere > 0 ? this.record.rateAtmosphere : '-'}/5`)
                  .fontSize(Theme.type.bodyS)
                  .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
              }
              Text('在「编辑赛事档案」中填写多维评分与观赛计划')
                .fontSize(Theme.type.caption)
                .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
            }
            .width('100%')
            .padding(Theme.space.s4)
            .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
            .borderRadius(Theme.radius.lg)
            .alignItems(HorizontalAlign.Start)

            Column({ space: Theme.space.s3 }) {
              Row() {
                Text(`关联瞬间 / 笔记 (${this.linked.length})`)
                  .fontSize(Theme.type.subhead)
                  .fontWeight(FontWeight.Medium)
                  .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
                Blank()
                Text('+ 添加')
                  .fontSize(Theme.type.bodyS)
                  .fontColor(Theme.colors().brandPrimary)
                  .onClick((): void => { this.showMoment = true })
              }
              .width('100%')
              if (this.linked.length === 0) {
                Text('把关键球和赛后感受挂到本场比赛，形成完整档案。')
                  .fontSize(Theme.type.bodyS)
                  .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
              } else {
                ForEach(this.linked, (it: CollectItem) => {
                  MomentCard({ item: it, onTap: (): void => {} })
                }, (it: CollectItem) => it.id)
              }
            }
            .width('100%')
            .padding(Theme.space.s4)
            .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
            .borderRadius(Theme.radius.lg)

            AppButton({ label: '标记为已看', variant: 'primary', onTap: (): void => { void this.markWatched() } })
            AppButton({ label: '生成比赛战报', variant: 'primary', onTap: (): void => { this.showReport = true } })
            AppButton({ label: '赛后复盘问卷', variant: 'secondary', onTap: (): void => { this.showRecap = true } })
            AppButton({ label: '复盘时间轴', variant: 'secondary', onTap: (): void => { this.showTimeline = true } })
            AppButton({ label: '编辑赛事档案', variant: 'secondary', onTap: (): void => { this.showEdit = true } })
          }
          .width('100%')
          .padding(Theme.space.pageX)
          .padding({ bottom: Theme.space.s10 })
        }
        .layoutWeight(1)
      }
      .width('100%')
      .height('100%')
      .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfacePage : Theme.colors().surfacePage)

      if (this.toastText.length > 0) {
        Text(this.toastText)
          .fontSize(Theme.type.bodyS)
          .fontColor(Theme.colors().textOnInverse)
          .padding({ left: 16, right: 16, top: 10, bottom: 10 })
          .backgroundColor(Theme.colors().brandDeep)
          .borderRadius(Theme.radius.pill)
          .position({ x: '8%', y: 48 })
          .zIndex(30)
      }
      if (this.showEdit) {
        RecordEditPage({
          editMode: true,
          seedId: this.record.id,
          onClose: (): void => { this.showEdit = false },
          onSaved: (_saved: SportRecord): void => { void this.reload() }
        })
      }
      if (this.showRecap) {
        RecapQuizPage({
          seedId: this.record.id,
          onClose: (): void => { this.showRecap = false },
          onSaved: (): void => { void this.reload() }
        })
      }
      if (this.showTimeline) {
        RecapTimelinePage({
          seedId: this.record.id,
          onClose: (): void => { this.showTimeline = false },
          onSaved: (): void => { void this.reload() }
        })
      }
      if (this.showMoment) {
        CollectEditPage({
          editKind: 'moment',
          seedId: '',
          refMatchId: this.record.id,
          onClose: (): void => { this.showMoment = false },
          onSaved: (): void => { void this.reload() }
        })
      }
      if (this.showReport) {
        MatchReportPage({
          seedId: this.record.id,
          onClose: (): void => { this.showReport = false }
        })
      }
    }
    .width('100%')
    .height('100%')
    .zIndex(75)
    .onAppear((): void => { AppStorage.setOrCreate('tabBarHidden', true) })
    .onDisAppear((): void => { AppStorage.setOrCreate('tabBarHidden', false) })
  }
}
