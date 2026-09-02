import { Theme } from '../design-system/Theme'
import { AppIcon } from '../design-system/AppIcon'
import { AskNav } from '../../services/AskNav'
import { GrowthStore } from '../../services/GrowthStore'
import { PathStore } from '../../services/PathStore'

class MissionRow {
  title: string = ''
  sub: string = ''
  type: string = ''
  done: boolean = false
}

@Component
export struct HomeTodayMission {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop @Watch('onRefreshTokenChange') refreshToken: number = 0
  @State missions: MissionRow[] = []
  @State doneCount: number = 0

  aboutToAppear(): void {
    this.reload()
  }

  onRefreshTokenChange(): void {
    this.reload()
  }

  private reload(): void {
    const rows: MissionRow[] = []
    const m1 = new MissionRow()
    m1.title = '完成 1 节路径章节'
    m1.sub = '结构化专题学习'
    m1.type = 'path'
    m1.done = GrowthStore.hasActivityToday('path')
    rows.push(m1)
    const m2 = new MissionRow()
    m2.title = '闪卡复习一轮'
    m2.sub = '卡片 + 错题巩固记忆'
    m2.type = 'card'
    m2.done = GrowthStore.hasActivityToday('card')
    rows.push(m2)
    const m3 = new MissionRow()
    m3.title = '阅读今日新知'
    m3.sub = '每日精选 + 轻量答题'
    m3.type = 'read'
    m3.done = GrowthStore.hasActivityToday('read')
    rows.push(m3)
    this.missions = rows
    this.doneCount = GrowthStore.todayMissionDoneCount()
  }

  private openMission(row: MissionRow): void {
    if (row.type === 'path') {
      void PathStore.ensureReady().then((): void => {
        const id = PathStore.firstIncompletePathId()
        if (id.length > 0) {
          AskNav.openPath(id)
          return
        }
        AskNav.switchTab(1)
      })
      return
    }
    if (row.type === 'card') {
      AskNav.openLearn('flashcards')
      return
    }
    AskNav.switchTab(3)
  }

  build() {
    Column({ space: Theme.space.s3 }) {
      Row() {
        Text('今日学习任务')
          .fontSize(Theme.type.subhead)
          .fontWeight(FontWeight.Medium)
          .fontColor(Theme.colorOf(this.themeEpoch).textPrimary)
        Blank()
        Text(`${this.doneCount}/3 已完成`)
          .fontSize(Theme.type.caption)
          .fontColor(Theme.colorOf(this.themeEpoch).brandPrimary)
      }
      .width('100%')
      ForEach(this.missions, (row: MissionRow) => {
        Row({ space: Theme.space.s3 }) {
          AppIcon({
            name: row.done ? 'check' : 'empty',
            iconSize: Theme.icon.sm,
            color: row.done ? Theme.colorOf(this.themeEpoch).brandPrimary :
              Theme.colorOf(this.themeEpoch).textTertiary
          })
          Column({ space: 2 }) {
            Text(row.title)
              .fontSize(Theme.type.body)
              .fontWeight(FontWeight.Medium)
              .fontColor(Theme.colorOf(this.themeEpoch).textPrimary)
            Text(row.sub)
              .fontSize(Theme.type.caption)
              .fontColor(Theme.colorOf(this.themeEpoch).textSecondary)
          }
          .layoutWeight(1)
          .alignItems(HorizontalAlign.Start)
          AppIcon({ name: 'chevron', iconSize: Theme.icon.sm })
        }
        .width('100%')
        .padding(Theme.space.s3)
        .backgroundColor(Theme.colorOf(this.themeEpoch).surfaceCard)
        .borderRadius(Theme.radius.card)
        .onClick((): void => { this.openMission(row) })
      }, (row: MissionRow) => row.type)
    }
    .width('100%')
  }
}
