import { Theme } from '../design-system/Theme'
import { AppButton } from '../design-system/AppButton'
import { AppIcon } from '../design-system/AppIcon'
import { MomentSection } from './MomentSection'
import { SportRecord, SportTypeOption } from '../../models/SportRecord'
import { KeyMoment, ResultOption } from '../../models/SportExtra'
import { WatchStatus, RecapPhase } from '../../models/CollectModels'
import { DateUtil } from '../../utils/DateUtil'
import { RecordStore } from '../../services/RecordStore'
import { StatisticsUtil } from '../../services/StatisticsUtil'

@Component
export struct SportRecordDetailPane {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop @Watch('onRecordPropChanged') record: SportRecord = new SportRecord()
  @Prop @Watch('onRefreshTokenChanged') refreshToken: number = 0
  @State viewRecord: SportRecord = new SportRecord()
  onClose: () => void = () => {}
  onDeleted: () => void = () => {}
  onEdit: () => void = () => {}
  onRecap: () => void = () => {}
  onTimeline: () => void = () => {}
  onWorkbench: () => void = () => {}
  onReport: () => void = () => {}
  @State moments: KeyMoment[] = []
  @State compareHint: string = ''
  @State confirmDelete: boolean = false

  aboutToAppear(): void {
    void this.syncFromStore()
  }

  onRecordPropChanged(): void {
    void this.syncFromStore()
  }

  onRefreshTokenChanged(): void {
    void this.syncFromStore()
  }

  private async syncFromStore(): Promise<void> {
    const id = this.record.id
    if (id.length > 0) {
      const fresh = await RecordStore.findById(id)
      if (fresh !== undefined) {
        this.viewRecord = fresh
        this.moments = KeyMoment.unpack(this.viewRecord.momentsPacked)
        void this.loadCompare()
        return
      }
    }
    this.viewRecord = SportRecord.cloneFrom(this.record)
    this.moments = KeyMoment.unpack(this.viewRecord.momentsPacked)
    void this.loadCompare()
  }

  private async loadCompare(): Promise<void> {
    const all = await RecordStore.loadAll()
    const prev = StatisticsUtil.previousSameSport(all, this.viewRecord)
    if (prev === undefined) {
      this.compareHint = '这是该运动类型的第一场可对照记录。'
      return
    }
    const longer = this.viewRecord.duration > prev.duration
    this.compareHint =
      `上场同项「${prev.title}」${prev.duration} 分钟` +
      (longer ? '，本场更久。' : '，本场更短或持平。')
  }

  private filledPhases(): RecapPhase[] {
    const out: RecapPhase[] = []
    for (const p of RecapPhase.unpack(this.viewRecord.recapPhases)) {
      if (p.text.length > 0) {
        out.push(p)
      }
    }
    return out
  }

  private persistMoments(list: KeyMoment[]): void {
    this.moments = list
    this.viewRecord.momentsPacked = KeyMoment.pack(list)
    void RecordStore.saveRecord(this.viewRecord)
  }

  private async doDelete(): Promise<void> {
    await RecordStore.deleteRecord(this.viewRecord.id)
    this.confirmDelete = false
    this.onDeleted()
  }

  build() {
    Stack() {
      Column()
        .width('100%')
        .height('100%')
        .backgroundColor(Theme.colors().overlayScrim)
        .onClick((): void => { this.onClose() })

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
          Text('赛事详情')
            .fontSize(Theme.type.subhead)
            .fontWeight(FontWeight.Medium)
            .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
          Blank()
          Column().width(44)
        }
        .width('100%')
        .padding(Theme.space.pageX)

        Scroll() {
          Column({ space: Theme.space.s4 }) {
            Stack({ alignContent: Alignment.BottomStart }) {
              Image($r('app.media.hero_sport_track'))
                .width('100%')
                .height(200)
                .objectFit(ImageFit.Cover)
                .borderRadius(Theme.radius.md)
              Column() {
                Blank()
                Column() {
                  Text(this.viewRecord.title.length > 0 ? this.viewRecord.title : '未命名赛事')
                    .fontSize(Theme.type.title3)
                    .fontWeight(FontWeight.Bold)
                    .fontColor('#FFFFFF')
                  Text(`${SportTypeOption.labelOf(this.viewRecord.sportType)} · ${DateUtil.displayDate(this.viewRecord.date)}`)
                    .fontSize(Theme.type.caption)
                    .fontColor('#FFFFFF')
                }
                .width('100%')
                .padding(Theme.space.s4)
                .linearGradient({
                  angle: 180,
                  colors: [['rgba(0,0,0,0)', 0], ['rgba(26,26,46,0.85)', 1]]
                })
              }
              .width('100%')
              .height('100%')
            }
            .width('100%')
            .height(200)

            Column({ space: Theme.space.s2 }) {
              Text(`清单 ${WatchStatus.label(this.viewRecord.status)}`)
                .fontSize(Theme.type.body)
                .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
              if (this.viewRecord.rating > 0) {
                Text(`个人评价 ${this.viewRecord.rating} 星`)
                  .fontSize(Theme.type.body)
                  .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
              }
              if (this.viewRecord.rateQuality > 0 || this.viewRecord.rateIntensity > 0 || this.viewRecord.rateAtmosphere > 0) {
                Text(`多维 质量${this.viewRecord.rateQuality}/强度${this.viewRecord.rateIntensity}/氛围${this.viewRecord.rateAtmosphere}`)
                  .fontSize(Theme.type.bodyS)
                  .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
              }
              if (this.viewRecord.watchPlan.length > 0) {
                Text(`观赛计划 ${this.viewRecord.watchPlan}`)
                  .fontSize(Theme.type.bodyS)
                  .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
              }
              if (ResultOption.labelOf(this.viewRecord.result).length > 0) {
                Text(`结果 ${ResultOption.labelOf(this.viewRecord.result)}`)
                  .fontSize(Theme.type.body)
                  .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
              }
              if (this.viewRecord.homeTeam.length > 0 || this.viewRecord.opponent.length > 0) {
                Text(`对阵 ${this.viewRecord.homeTeam} vs ${this.viewRecord.opponent}`)
                  .fontSize(Theme.type.body)
                  .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
              }
              if (this.viewRecord.location.length > 0) {
                Text(`地点 ${this.viewRecord.location}`)
                  .fontSize(Theme.type.body)
                  .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
              }
              if (this.viewRecord.duration > 0) {
                Text(`时长 ${this.viewRecord.duration} 分钟`)
                  .fontSize(Theme.type.body)
                  .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
              }
              if (this.viewRecord.score.length > 0) {
                Text(`成绩 ${this.viewRecord.score}`)
                  .fontSize(Theme.type.body)
                  .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
              }
              if (this.viewRecord.prediction.length > 0) {
                Text(`赛前预测 ${this.viewRecord.prediction}`)
                  .fontSize(Theme.type.body)
                  .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
              }
              if (this.viewRecord.mvpName.length > 0) {
                Text(`本场 MVP ${this.viewRecord.mvpName}`)
                  .fontSize(Theme.type.body)
                  .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
              }
              Text(this.compareHint)
                .fontSize(Theme.type.bodyS)
                .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
            }
            .width('100%')
            .padding(Theme.space.s4)
            .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
            .borderRadius(Theme.radius.lg)

            if (this.viewRecord.recapPhases.length > 0) {
              Column({ space: Theme.space.s2 }) {
                Text('复盘时间轴')
                  .fontSize(Theme.type.subhead)
                  .fontWeight(FontWeight.Medium)
                  .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
                ForEach(this.filledPhases(), (p: RecapPhase) => {
                  Text(`${p.label}：${p.text}`)
                    .fontSize(Theme.type.bodyS)
                    .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
                }, (p: RecapPhase) => p.id)
              }
              .width('100%')
              .padding(Theme.space.s4)
              .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
              .borderRadius(Theme.radius.lg)
              .alignItems(HorizontalAlign.Start)
            }

            if (this.viewRecord.recapSummary.length > 0) {
              Column({ space: Theme.space.s2 }) {
                Text(`复盘 · ${this.viewRecord.recapScore}`)
                  .fontSize(Theme.type.subhead)
                  .fontWeight(FontWeight.Medium)
                  .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
                Text(this.viewRecord.recapSummary)
                  .fontSize(Theme.type.bodyS)
                  .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
              }
              .width('100%')
              .padding(Theme.space.s4)
              .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
              .borderRadius(Theme.radius.lg)
            }

            if (this.viewRecord.note.length > 0) {
              Text(this.viewRecord.note)
                .fontSize(Theme.type.body)
                .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
                .width('100%')
            }

            MomentSection({
              moments: this.moments,
              onChanged: (list: KeyMoment[]): void => { this.persistMoments(list) }
            })

            AppButton({
              label: '打开比赛工作台',
              variant: 'primary',
              onTap: (): void => { this.onWorkbench() }
            })
            AppButton({
              label: '生成比赛战报',
              variant: 'secondary',
              onTap: (): void => { this.onReport() }
            })
            AppButton({
              label: this.viewRecord.recapSummary.length > 0 ? '重做赛后复盘问卷' : '赛后复盘问卷',
              variant: 'secondary',
              onTap: (): void => { this.onRecap() }
            })
            AppButton({
              label: '填写复盘时间轴',
              variant: 'secondary',
              onTap: (): void => { this.onTimeline() }
            })
            AppButton({
              label: '编辑记录',
              variant: 'secondary',
              onTap: (): void => { this.onEdit() }
            })
            AppButton({
              label: '删除记录',
              variant: 'secondary',
              onTap: (): void => { this.confirmDelete = true }
            })
          }
          .width('100%')
          .padding(Theme.space.pageX)
          .padding({ bottom: Theme.space.s10 })
        }
        .layoutWeight(1)
        .edgeEffect(EdgeEffect.Spring)
      }
      .width('100%')
      .height('92%')
      .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfacePage : Theme.colors().surfacePage)
      .borderRadius({ topLeft: Theme.radius.xl, topRight: Theme.radius.xl })
      .position({ x: 0, y: '8%' })

      if (this.confirmDelete) {
        Column({ space: Theme.space.s4 }) {
          Text('删除后无法恢复，确认删除本场？')
            .fontSize(Theme.type.body)
            .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
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
        .width('80%')
        .padding(Theme.space.s5)
        .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
        .borderRadius(Theme.radius.xl)
      }
    }
    .width('100%')
    .height('100%')
    .zIndex(50)
    .onAppear((): void => { AppStorage.setOrCreate('tabBarHidden', true) })
    .onDisAppear((): void => { AppStorage.setOrCreate('tabBarHidden', false) })
  }
}
