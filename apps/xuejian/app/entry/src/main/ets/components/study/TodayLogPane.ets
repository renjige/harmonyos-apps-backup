import { Theme } from '../design-system/Theme'
import { AppButton } from '../design-system/AppButton'
import { AppEmpty } from '../design-system/AppEmpty'
import { AppIcon } from '../design-system/AppIcon'
import { StudySession } from '../../models/StudyModels'
import { StudyStore } from '../../services/StudyStore'

@Component
export struct TodayLogPane {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @State sessions: StudySession[] = []
  @State customText: string = '25'
  @State toastText: string = ''
  @State confirmId: string = ''
  onClose: () => void = () => {}
  onChanged: () => void = () => {}
  onOpenFocus: () => void = () => {}

  aboutToAppear(): void {
    void this.load()
  }

  private async load(): Promise<void> {
    const all = await StudyStore.loadSessions()
    const key = StudyStore.dateKey(Date.now())
    const today: StudySession[] = []
    for (const s of all) {
      if (StudyStore.dateKey(s.endedAt) === key) {
        today.push(s)
      }
    }
    this.sessions = today
  }

  private showToast(msg: string): void {
    this.toastText = msg
    setTimeout((): void => { this.toastText = '' }, 2200)
  }

  private async logMinutes(mins: number): Promise<void> {
    if (mins < 1 || mins > 180) {
      this.showToast('请填写 1–180 分钟')
      return
    }
    const session = StudySession.create(mins, mins, false)
    await StudyStore.addSession(session)
    this.onChanged()
    await this.load()
    this.showToast(`已补记 ${mins} 分钟`)
  }

  private async remove(id: string): Promise<void> {
    if (this.confirmId !== id) {
      this.confirmId = id
      this.showToast('再点一次删除确认')
      return
    }
    await StudyStore.deleteSession(id)
    this.confirmId = ''
    this.onChanged()
    await this.load()
    this.showToast('已删除本条时长')
  }

  build() {
    Stack({ alignContent: Alignment.Top }) {
      Column() {
        Row() {
          Row() {
            AppIcon({ name: 'close', iconSize: Theme.icon.lg, color: Theme.colors().textPrimary })
          }
          .width(48).height(48).justifyContent(FlexAlign.Center)
          .onClick((): void => { this.onClose() })
          Text('今日学习记录')
            .fontSize(Theme.type.subtitleM)
            .fontWeight(FontWeight.Medium)
            .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
            .layoutWeight(1)
        }
        .width('100%')

        Scroll() {
          Column({ space: Theme.space.s4 }) {
            Text('点「补记」即可写入今日时长，不必等倒计时结束。')
              .fontSize(Theme.type.bodyS)
              .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
              .width('100%')

            Row({ space: 8 }) {
              this.LogChip(15)
              this.LogChip(25)
              this.LogChip(45)
            }
            .width('100%')

            Row({ space: 8 }) {
              TextInput({ text: this.customText, placeholder: '自定义分钟' })
                .layoutWeight(1)
                .height(44)
                .fontColor(Theme.inputInk())
                .placeholderColor(Theme.inputHint())
                .backgroundColor(Theme.inputFill())
                .border({ width: 1, color: '#CBD5E1' })
                .borderRadius(12)
                .onChange((v: string) => { this.customText = v })
              Text('补记')
                .fontSize(Theme.type.body)
                .fontWeight(FontWeight.Medium)
                .fontColor('#FFFFFF')
                .padding({ left: 16, right: 16, top: 12, bottom: 12 })
                .backgroundColor('#1A2A4A')
                .borderRadius(16)
                .constraintSize({ minHeight: 44 })
                .onClick((): void => {
                  const n = Number.parseInt(this.customText, 10)
                  void this.logMinutes(n)
                })
            }
            .width('100%')

            AppButton({
              label: '打开专注倒计时',
              onTap: (): void => { this.onOpenFocus() }
            })

            Text('今日明细')
              .fontSize(Theme.type.subtitleS)
              .fontWeight(FontWeight.Medium)
              .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
              .width('100%')

            if (this.sessions.length === 0) {
              AppEmpty({
                title: '今天还没有时长',
                description: '补记一笔，或开始一段专注',
                actionLabel: '补记 25 分钟',
                onAction: (): void => { void this.logMinutes(25) }
              })
            } else {
              ForEach(this.sessions, (s: StudySession) => {
                Row() {
                  Column({ space: 4 }) {
                    Text(`${s.minutes} 分钟`)
                      .fontSize(Theme.type.body)
                      .fontWeight(FontWeight.Medium)
                      .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
                    Text(StudyStore.timeLabel(s.endedAt))
                      .fontSize(Theme.type.caption)
                      .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
                  }
                  .alignItems(HorizontalAlign.Start)
                  .layoutWeight(1)
                  Text('删除')
                    .fontSize(Theme.type.bodyS)
                    .fontColor(Theme.colors().danger)
                    .constraintSize({ minHeight: 44 })
                    .onClick((): void => { void this.remove(s.id) })
                }
                .width('100%')
                .padding(12)
                .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
                .borderRadius(14)
              }, (s: StudySession) => s.id)
            }
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
      .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfacePage : Theme.colors().surfacePage)

      if (this.toastText.length > 0) {
        Text(this.toastText)
          .fontSize(Theme.type.bodyS)
          .fontColor('#FFFFFF')
          .padding(12)
          .backgroundColor('#1A2A4A')
          .borderRadius(12)
          .margin({ top: 16 })
      }
    }
    .width('100%')
    .height('100%')
  }

  @Builder
  LogChip(mins: number) {
    Text(`补记 ${mins} 分`)
      .fontSize(Theme.type.bodyS)
      .fontColor('#FFFFFF')
      .padding({ left: 12, right: 12, top: 10, bottom: 10 })
      .backgroundColor('#1A2A4A')
      .borderRadius(16)
      .constraintSize({ minHeight: 44 })
      .onClick((): void => { void this.logMinutes(mins) })
  }
}
