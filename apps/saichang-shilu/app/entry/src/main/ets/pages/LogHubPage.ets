import { Theme } from '../components/design-system/Theme'
import { AppEmpty } from '../components/design-system/AppEmpty'
import { ChallengeBar, MomentCard } from '../components/sport/SportCards'
import { CollectDetailPane } from '../components/sport/CollectDetailPane'
import { CollectItem, DashStats } from '../models/CollectModels'
import { CollectStore } from '../services/CollectStore'
import { MemoryStats } from '../services/MemoryStats'
import { RecordStore } from '../services/RecordStore'
import { CollectEditPage } from './CollectEditPage'
import { RecapQuizPage } from './RecapQuizPage'
import { RecapTimelinePage } from './RecapTimelinePage'
import { MemoryTimelinePage } from './MemoryTimelinePage'

@Component
export struct LogHubPage {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @State moments: CollectItem[] = []
  @State notes: CollectItem[] = []
  @State dash: DashStats = new DashStats()
  @State pendingId: string = ''
  @State showEdit: boolean = false
  @State editKind: string = 'moment'
  @State editSeed: string = ''
  @State detail: CollectItem | undefined = undefined
  @State showRecap: boolean = false
  @State showTimeline: boolean = false
  @State showMemoryTimeline: boolean = false
  @Prop reloadToken: number = 0
  @State lastToken: number = -1

  aboutToAppear(): void {
    void this.reload()
  }

  private async reload(): Promise<void> {
    this.moments = await CollectStore.loadKind('moment')
    this.notes = await CollectStore.loadKind('note')
    this.dash = await MemoryStats.dash()
    const matches = await RecordStore.loadAll()
    this.pendingId = ''
    for (const it of matches) {
      if (it.recapSummary.length === 0 && it.recapPhases.length === 0) {
        this.pendingId = it.id
        break
      }
    }
  }

  private openNew(kind: string): void {
    this.editKind = kind
    this.editSeed = ''
    this.showEdit = true
  }

  build() {
    Stack() {
      Scroll() {
        Column({ space: Theme.space.s5 }) {
          Stack({ alignContent: Alignment.BottomStart }) {
            Image($r('app.media.banner_monthly'))
              .width('100%')
              .height(132)
              .objectFit(ImageFit.Cover)
              .borderRadius(Theme.radius.xl)
            Column() {
              Blank()
              Column({ space: 4 }) {
                Text('记录中心')
                  .fontSize(Theme.type.subhead)
                  .fontWeight(FontWeight.Bold)
                  .fontColor('#FFFFFF')
                Text('瞬间 · 笔记 · 复盘 · 挑战')
                  .fontSize(Theme.type.caption)
                  .fontColor('#FFFFFF')
              }
              .width('100%')
              .padding(Theme.space.s4)
              .linearGradient({
                angle: 180,
                colors: [['rgba(0,0,0,0)', 0], ['rgba(26,26,46,0.88)', 1]]
              })
            }
            .width('100%')
            .height('100%')
          }
          .width('100%')
          .height(132)

          Column({ space: Theme.space.s3 }) {
            Text('本周挑战')
              .fontSize(Theme.type.subhead)
              .fontWeight(FontWeight.Medium)
              .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
            ChallengeBar({ label: '记录 3 场比赛', current: this.dash.weekMatches, target: 3 })
            ChallengeBar({ label: '完成 2 次复盘', current: this.dash.weekRecaps, target: 2 })
            ChallengeBar({ label: '写下 5 条瞬间', current: this.dash.weekMoments, target: 5 })
          }
          .width('100%')
          .padding(Theme.space.s4)
          .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
          .borderRadius(Theme.radius.lg)

          Row({ space: Theme.space.s3 }) {
            this.ActionChip('写瞬间', (): void => { this.openNew('moment') })
            this.ActionChip('写笔记', (): void => { this.openNew('note') })
          }
          .width('100%')
          if (this.pendingId.length > 0) {
            Row({ space: Theme.space.s3 }) {
              this.ActionChip('复盘问卷', (): void => { this.showRecap = true })
              this.ActionChip('复盘时间轴', (): void => { this.showTimeline = true })
            }
            .width('100%')
          }

          Text('记录模板')
            .fontSize(Theme.type.subhead)
            .fontWeight(FontWeight.Medium)
            .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
          Row({ space: Theme.space.s2 }) {
            this.TemplateChip('关键球瞬间', '第78分钟 · 改变走势', (): void => { this.openNew('moment') })
            this.TemplateChip('赛后随笔', '比赛感受', (): void => { this.openNew('note') })
          }
          .width('100%')

          Row() {
            Text('赛场瞬间墙')
              .fontSize(Theme.type.subhead)
              .fontWeight(FontWeight.Medium)
              .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
            Blank()
            Text('时间轴 →')
              .fontSize(Theme.type.bodyS)
              .fontColor(Theme.colors().brandPrimary)
              .onClick((): void => { this.showMemoryTimeline = true })
          }
          .width('100%')

          if (this.moments.length === 0) {
            AppEmpty({
              title: '还没有精彩瞬间卡片',
              description: '用标题、时间节点和描述记下关键球，不调用相册',
              actionLabel: '添加瞬间',
              onAction: (): void => { this.openNew('moment') }
            })
          } else {
            ForEach(this.moments, (it: CollectItem) => {
              MomentCard({
                item: it,
                onTap: (): void => { this.detail = it }
              })
            }, (it: CollectItem) => it.id)
          }

          Text('赛场笔记')
            .fontSize(Theme.type.subhead)
            .fontWeight(FontWeight.Medium)
            .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
          if (this.notes.length === 0) {
            Text('赛前期待、赛后总结或球迷随笔都可以记在这里。')
              .fontSize(Theme.type.bodyS)
              .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
          } else {
            ForEach(this.notes, (it: CollectItem) => {
              this.NoteRow(it)
            }, (it: CollectItem) => it.id)
          }
        }
        .width('100%')
        .padding(Theme.space.pageX)
        .padding({ bottom: Theme.space.s10 })
      }
      .width('100%')
      .height('100%')
      .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfacePage : Theme.colors().surfacePage)
      .edgeEffect(EdgeEffect.Spring)

      if (this.detail !== undefined) {
        CollectDetailPane({
          item: this.detail,
          onClose: (): void => { this.detail = undefined },
          onDeleted: (): void => { this.detail = undefined; void this.reload() },
          onEdit: (): void => {
            this.editKind = (this.detail as CollectItem).kind
            this.editSeed = (this.detail as CollectItem).id
            this.detail = undefined
            this.showEdit = true
          }
        })
      }
      if (this.showEdit) {
        CollectEditPage({
          editKind: this.editKind,
          seedId: this.editSeed,
          onClose: (): void => { this.showEdit = false },
          onSaved: (): void => { void this.reload() }
        })
      }
      if (this.showRecap && this.pendingId.length > 0) {
        RecapQuizPage({
          seedId: this.pendingId,
          onClose: (): void => { this.showRecap = false },
          onSaved: (): void => { void this.reload() }
        })
      }
      if (this.showTimeline && this.pendingId.length > 0) {
        RecapTimelinePage({
          seedId: this.pendingId,
          onClose: (): void => { this.showTimeline = false },
          onSaved: (): void => { void this.reload() }
        })
      }
      if (this.showMemoryTimeline) {
        MemoryTimelinePage({ onClose: (): void => { this.showMemoryTimeline = false } })
      }
    }
    .width('100%')
    .height('100%')
    .onAppear((): void => {
      if (this.reloadToken !== this.lastToken) {
        this.lastToken = this.reloadToken
        void this.reload()
      }
    })
  }

  @Builder
  ActionChip(label: string, onTap: () => void) {
    Text(label)
      .fontSize(Theme.type.bodyS)
      .fontColor(Theme.colors().brandOnPrimary)
      .padding({ left: 14, right: 14, top: 10, bottom: 10 })
      .backgroundColor(Theme.colors().brandPrimary)
      .borderRadius(Theme.radius.pill)
      .layoutWeight(1)
      .textAlign(TextAlign.Center)
      .onClick(onTap)
  }

  @Builder
  TemplateChip(title: string, hint: string, onTap: () => void) {
    Column({ space: 4 }) {
      Text(title)
        .fontSize(Theme.type.bodyS)
        .fontWeight(FontWeight.Medium)
        .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
      Text(hint)
        .fontSize(Theme.type.caption)
        .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
    }
    .layoutWeight(1)
    .padding(Theme.space.s3)
    .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
    .borderRadius(Theme.radius.lg)
    .onClick(onTap)
  }

  @Builder
  NoteRow(it: CollectItem) {
    Column({ space: 4 }) {
      Text(`${it.extra.length > 0 ? it.extra : '笔记'} · ${it.title}`)
        .fontSize(Theme.type.subhead)
        .fontWeight(FontWeight.Medium)
        .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
      Text(it.body.length > 0 ? it.body : it.sub)
        .fontSize(Theme.type.caption)
        .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
        .maxLines(2)
    }
    .width('100%')
    .alignItems(HorizontalAlign.Start)
    .padding(Theme.space.s4)
    .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
    .borderRadius(Theme.radius.lg)
    .onClick((): void => { this.detail = it })
  }
}
