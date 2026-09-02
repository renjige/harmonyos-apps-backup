import { Theme } from '../design-system/Theme'
import { PracticeDay, PracticeStore } from '../../services/PracticeStore'
import { EssayStore } from '../../services/EssayStore'

@Component
export struct PracticeStrip {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @StorageLink('essayDataEpoch') @Watch('onData') dataEpoch: number = 0
  @Prop fontScale: number = 1
  onWrite: (hint: string) => void = (hint: string) => {
    if (hint.length === 0) {
      return
    }
  }

  @State lessons: PracticeDay[] = []
  @State doneCount: number = 0
  @State hintLine: string = '点一个感官。本周写过该感官才会亮起，不是只勾选。'
  @State canWrite: boolean = false
  @State writeHint: string = ''
  @State activeTitle: string = ''

  aboutToAppear(): void {
    void this.refresh()
  }

  onData(): void {
    void this.refresh()
  }

  private async refresh(): Promise<void> {
    const week = await EssayStore.loadWeek()
    this.lessons = PracticeStore.applyWeekDone(PracticeStore.lessons(), week)
    this.doneCount = PracticeStore.writtenCount(this.lessons)
  }

  private onLesson(item: PracticeDay): void {
    this.activeTitle = item.title
    this.writeHint = item.hint
    this.canWrite = true
    if (item.done) {
      this.hintLine = `本周已写过「${item.title}」。可再写一篇加深。`
    } else {
      this.hintLine = `还没写「${item.title}」：${item.hint}`
    }
  }

  build() {
    Column({ space: Theme.space.s2 }) {
      Row() {
        Text('七日微观察')
          .fontSize(Theme.type.subhead * this.fontScale)
          .fontWeight(FontWeight.Medium)
          .fontColor(Theme.colors().textPrimary)
        Blank()
        Text(`${this.doneCount}/7 已写`)
          .fontSize(Theme.type.caption)
          .fontColor(Theme.colors().textSecondary)
      }
      .width('100%')

      Text('亮起表示本周已写下该感官。点选后提示会立刻换成课题说明。')
        .fontSize(Theme.type.caption * this.fontScale)
        .fontColor(Theme.colors().textSecondary)
        .width('100%')

      Flex({ wrap: FlexWrap.Wrap }) {
        ForEach(this.lessons, (item: PracticeDay) => {
          Text(item.done ? `${item.title} ✓` : item.title)
            .fontSize(Theme.type.bodyS)
            .fontColor(item.done || item.title === this.activeTitle ? '#FFFFFF' : Theme.colors().textPrimary)
            .padding({ left: 12, right: 12, top: 8, bottom: 8 })
            .backgroundColor(item.done || item.title === this.activeTitle ? '#1A2A3A' : Theme.colors().brandPrimaryContainer)
            .borderRadius(Theme.radius.pill)
            .margin({ right: 8, bottom: 8 })
            .onClick((): void => { this.onLesson(item) })
        }, (item: PracticeDay) => `${item.index}_${item.done}_${this.doneCount}_${this.activeTitle}`)
      }
      .width('100%')

      Text(this.hintLine)
        .fontSize(Theme.type.bodyS * this.fontScale)
        .fontColor(Theme.colors().textPrimary)
        .width('100%')

      if (this.canWrite && this.writeHint.length > 0) {
        Text(`按「${this.activeTitle}」写一篇`)
          .fontSize(Theme.type.bodyS)
          .fontWeight(FontWeight.Medium)
          .fontColor('#FFFFFF')
          .padding({ left: 12, right: 12, top: 8, bottom: 8 })
          .backgroundColor('#C9A96E')
          .borderRadius(Theme.radius.pill)
          .onClick((): void => { this.onWrite(this.writeHint) })
      }
    }
    .width('100%')
    .padding(Theme.space.s4)
    .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
    .borderRadius(Theme.radius.md)
  }
}
