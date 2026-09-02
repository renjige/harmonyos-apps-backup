import { Theme } from '../design-system/Theme'
import { AppButton } from '../design-system/AppButton'
import { AppEmpty } from '../design-system/AppEmpty'
import { DayStudyLine, DayStudySummary } from '../../models/StudyModels'
import { StudyStore } from '../../services/StudyStore'

@Component
export struct DayStudyPane {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop dateKey: string = ''
  @State summary: DayStudySummary = new DayStudySummary()
  @State loaded: boolean = false
  onClose: () => void = () => {}
  onOpenNote: (id: string) => void = (_id: string) => {}
  onOpenCard: (id: string) => void = (_id: string) => {}
  onOpenFocus: () => void = () => {}

  aboutToAppear(): void {
    void this.load()
  }

  private async load(): Promise<void> {
    this.summary = await StudyStore.daySnapshot(this.dateKey)
    this.loaded = true
  }

  private openLine(line: DayStudyLine): void {
    if (line.kind === 'note') {
      this.onOpenNote(line.id)
      return
    }
    if (line.kind === 'card') {
      this.onOpenCard(line.id)
    }
  }

  build() {
    Column() {
      Row() {
        Text('返回')
          .fontSize(Theme.type.body)
          .fontColor(Theme.colors().textPrimary)
          .constraintSize({ minHeight: 44 })
          .onClick((): void => { this.onClose() })
        Text('学习日记')
          .fontSize(Theme.type.subtitleM)
          .fontWeight(FontWeight.Medium)
          .fontColor(Theme.colors().textPrimary)
          .layoutWeight(1)
          .textAlign(TextAlign.Center)
        Blank().width(44)
      }
      .width('100%')
      .padding({ left: Theme.space.pageX, right: Theme.space.pageX })

      Scroll() {
        Column({ space: Theme.space.s4 }) {
          Column({ space: 8 }) {
            Text(this.summary.dateLabel)
              .fontSize(Theme.type.title2)
              .fontWeight(FontWeight.Bold)
              .fontColor(Theme.colors().textPrimary)
              .width('100%')
            Text(`专注 ${this.summary.totalMinutes} 分钟 · ${this.summary.lines.length} 条记录`)
              .fontSize(Theme.type.bodyS)
              .fontColor(Theme.bodyMuted())
              .width('100%')
            if (this.summary.checkinLine.length > 0) {
              Text(`今日一句：${this.summary.checkinLine}`)
                .fontSize(Theme.type.body)
                .fontColor(Theme.colors().textPrimary)
                .width('100%')
                .padding(12)
                .backgroundColor(Theme.isDark() ? '#3A4558' : '#EFEAE3')
                .borderRadius(12)
            }
          }
          .width('100%')

          if (this.loaded && this.summary.lines.length === 0 && this.summary.checkinLine.length === 0) {
            AppEmpty({
              title: '这一天还没有记录',
              description: '可以补记时长、写笔记或建卡片',
              actionLabel: '开始专注',
              onAction: (): void => { this.onOpenFocus() }
            })
          } else {
            ForEach(this.summary.lines, (line: DayStudyLine) => {
              Column({ space: 4 }) {
                Text(line.title)
                  .fontSize(Theme.type.body)
                  .fontWeight(FontWeight.Medium)
                  .fontColor(Theme.colors().textPrimary)
                  .width('100%')
                Text(`${line.subtitle} · ${StudyStore.timeLabel(line.at)}`)
                  .fontSize(Theme.type.caption)
                  .fontColor(Theme.bodyMuted())
                  .width('100%')
              }
              .width('100%')
              .padding(12)
              .backgroundColor(Theme.colors().surfaceCard)
              .borderRadius(12)
              .onClick((): void => { this.openLine(line) })
            }, (line: DayStudyLine) => line.id)
          }

          AppButton({ label: '为今天开始专注', onTap: (): void => { this.onOpenFocus() } })
        }
        .padding({
          left: Theme.space.pageX,
          right: Theme.space.pageX,
          bottom: Theme.space.s10
        })
      }
      .layoutWeight(1)
    }
    .width('100%')
    .height('100%')
    .backgroundColor(Theme.colors().surfacePage)
  }
}
