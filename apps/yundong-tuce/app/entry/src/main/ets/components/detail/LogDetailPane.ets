import { Theme } from '../design-system/Theme'
import { AppButton } from '../design-system/AppButton'
import { TrainLog } from '../../models/TuceModels'
import { TuceStore } from '../../services/TuceStore'
import { TuceNav } from '../../services/TuceNav'

@Component
export struct LogDetailPane {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop logId: string = ''
  @State log: TrainLog = new TrainLog()
  @State confirm: boolean = false

  aboutToAppear(): void {
    void this.load()
  }

  private async load(): Promise<void> {
    const list = await TuceStore.logs()
    for (const it of list) {
      if (it.id === this.logId) {
        this.log = it
      }
    }
  }

  private async remove(): Promise<void> {
    if (!this.confirm) {
      this.confirm = true
      return
    }
    await TuceStore.deleteLog(this.log.id)
    TuceNav.bump()
    TuceNav.close()
  }

  build() {
    Column({ space: Theme.space.s3 }) {
      Text(this.log.planName)
        .fontSize(Theme.type.title2)
        .fontWeight(FontWeight.Bold)
        .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
        .width('100%')
      Text(this.log.date)
        .fontSize(Theme.type.bodyS)
        .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
        .width('100%')
      Text(this.log.doneText)
        .fontSize(Theme.type.body)
        .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
        .width('100%')
      if (this.log.feel.length > 0) {
        Text(`感受：${this.log.feel}`)
          .fontSize(Theme.type.bodyS)
          .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
          .width('100%')
      }
      Text(`难度 ${this.log.difficulty} · 趣味 ${this.log.fun} · 完成感 ${this.log.complete}`)
        .fontSize(Theme.type.bodyS)
        .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
        .width('100%')
      if (this.log.note.length > 0) {
        Text(this.log.note)
          .fontSize(Theme.type.body)
          .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
          .width('100%')
      }
      AppButton({
        label: this.confirm ? '再点一次确认删除' : '删除这条日志',
        variant: 'secondary',
        onTap: (): void => { void this.remove() }
      })
    }
    .width('100%')
    .height('100%')
    .padding({ left: Theme.space.pageX, right: Theme.space.pageX, bottom: Theme.space.s10 })
  }
}
