import { Theme } from '../design-system/Theme'
import { AppButton } from '../design-system/AppButton'
import { DetailShell } from '../detail/DetailShell'
import { TrainingLog } from '../../models/SaituSportModels'
import { SaituLocalStore } from '../../services/SaituLocalStore'
import { SaituSportStore } from '../../services/SaituSportStore'
import { SaituDetailNav } from '../../services/SaituDetailNav'

@Component
export struct TrainingLogDetail {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @StorageLink('saituTrainingDetailId') @Watch('onIdChange') trainingId: string = ''
  onChanged: () => void = () => {}
  @State item: TrainingLog = new TrainingLog()
  @State journeyName: string = ''
  @State confirmDelete: boolean = false
  @State toastText: string = ''

  aboutToAppear(): void {
    void this.reload()
  }

  onIdChange(): void {
    void this.reload()
  }

  private async reload(): Promise<void> {
    const found = await SaituSportStore.findTraining(this.trainingId)
    if (found !== undefined) {
      this.item = found
      if (found.journeyId.length > 0) {
        const j = await SaituLocalStore.findJourney(found.journeyId)
        this.journeyName = j !== undefined ? j.name : ''
      } else {
        this.journeyName = ''
      }
    }
  }

  private async doDelete(): Promise<void> {
    await SaituSportStore.deleteTraining(this.item.id)
    this.confirmDelete = false
    SaituDetailNav.closeTrainingDetail()
    this.onChanged()
  }

  @Builder
  bodyContent() {
    Scroll() {
      Column({ space: Theme.space.s4 }) {
        Column({ space: Theme.space.s2 }) {
          Text('训练日志')
            .fontSize(Theme.type.caption)
            .fontColor(Theme.colors().brandOnPrimary)
          Text(this.item.title)
            .fontSize(Theme.type.title3)
            .fontWeight(FontWeight.Bold)
            .fontColor(Theme.colors().textOnInverse)
            .width('100%')
          Text(`${this.item.logDate} · ${this.item.typeLabel()}`)
            .fontSize(Theme.type.bodyS)
            .fontColor(Theme.colors().textOnInverse)
        }
        .width('100%')
        .alignItems(HorizontalAlign.Start)
        .padding(Theme.space.s5)
        .linearGradient({
          angle: 140,
          colors: [[Theme.colors().brandDeep, 0], [Theme.colors().brandPrimary, 1]]
        })
        .borderRadius(Theme.radius.lg)

        Row({ space: Theme.space.s4 }) {
          Column({ space: 4 }) {
            Text(`${this.item.durationMin}`)
              .fontSize(28)
              .fontWeight(FontWeight.Bold)
              .fontColor(Theme.colors().brandPrimary)
            Text('分钟')
              .fontSize(Theme.type.caption)
              .fontColor(Theme.colors().textSecondary)
          }
          Column({ space: 4 }) {
            Text(`${this.item.intensity}`)
              .fontSize(28)
              .fontWeight(FontWeight.Bold)
              .fontColor(Theme.colors().brandPrimary)
            Text('强度')
              .fontSize(Theme.type.caption)
              .fontColor(Theme.colors().textSecondary)
          }
        }
        .width('100%')
        .padding(Theme.space.cardPadding)
        .backgroundColor(Theme.colors().surfaceCard)
        .borderRadius(Theme.radius.lg)

        if (this.journeyName.length > 0) {
          Text(`关联旅途 · ${this.journeyName}`)
            .fontSize(Theme.type.bodyS)
            .fontColor(Theme.colors().brandPrimary)
        }

        Text(this.item.body.length > 0 ? this.item.body : '未填写训练细节，可编辑补充。')
          .fontSize(Theme.type.body)
          .fontColor(Theme.colors().textPrimary)
          .lineHeight(24)
          .width('100%')

        Column({ space: Theme.space.s3 }) {
          AppButton({
            label: '编辑',
            variant: 'primary',
            onTap: (): void => SaituDetailNav.openTrainingEditor(this.item.id)
          })
          AppButton({
            label: '删除',
            variant: 'secondary',
            onTap: (): void => { this.confirmDelete = true }
          })
        }
        .width('100%')
        Blank().height(Theme.space.s10)
      }
      .padding({ left: Theme.space.pageX, right: Theme.space.pageX, bottom: Theme.space.s6 })
    }
    .scrollBar(BarState.Off)
  }

  build() {
    Stack({ alignContent: Alignment.Top }) {
      DetailShell({
        title: '训练日志',
        onClose: (): void => SaituDetailNav.closeTrainingDetail(),
        body: (): void => this.bodyContent()
      })
      if (this.confirmDelete) {
        Column({ space: Theme.space.s3 }) {
          Text('确认删除这条训练记录？')
            .fontSize(Theme.type.body)
            .fontColor(Theme.colors().textPrimary)
          AppButton({ label: '取消', variant: 'secondary', onTap: (): void => { this.confirmDelete = false } })
          AppButton({ label: '确认删除', variant: 'danger', onTap: (): void => { void this.doDelete() } })
        }
        .width('80%')
        .padding(Theme.space.s6)
        .backgroundColor(Theme.colors().surfaceCard)
        .borderRadius(Theme.radius.xl)
        .position({ x: '10%', y: '32%' })
      }
    }
    .width('100%')
    .height('100%')
  }
}
