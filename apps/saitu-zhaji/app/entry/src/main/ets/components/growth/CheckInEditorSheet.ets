import { Theme } from '../design-system/Theme'
import { AppButton } from '../design-system/AppButton'
import { AppNavBar } from '../design-system/AppNavBar'
import { Journey } from '../../models/SaituModels'
import { CheckIn } from '../../models/SaituGrowthModels'
import { SaituLocalStore } from '../../services/SaituLocalStore'
import { SaituCheckInStore } from '../../services/SaituCheckInStore'
import { SaituDetailNav } from '../../services/SaituDetailNav'
import { SaituAchievementStore } from '../../services/SaituAchievementStore'

@Component
export struct CheckInEditorSheet {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @StorageLink('saituCheckInJourneyId') journeyPrefill: string = ''
  onSaved: () => void = () => {}
  @State journeys: Journey[] = []
  @State selectedJourneyId: string = ''
  @State note: string = ''
  @State toastText: string = ''
  @State existing: CheckIn | undefined = undefined

  aboutToAppear(): void {
    void this.bootstrap()
  }

  private showToast(msg: string): void {
    this.toastText = msg
    setTimeout((): void => { this.toastText = '' }, 2600)
  }

  private async bootstrap(): Promise<void> {
    this.journeys = await SaituLocalStore.loadJourneys()
    this.existing = await SaituCheckInStore.todayCheckIn()
    if (this.existing !== undefined) {
      this.selectedJourneyId = this.existing.journeyId
      this.note = this.existing.note
    } else if (this.journeyPrefill.length > 0) {
      this.selectedJourneyId = this.journeyPrefill
    } else if (this.journeys.length > 0) {
      this.selectedJourneyId = this.journeys[0].id
    }
  }

  private async save(): Promise<void> {
    if (this.selectedJourneyId.length === 0) {
      this.showToast('请先创建并选择旅途')
      return
    }
    let item = this.existing
    if (item === undefined) {
      item = CheckIn.create(this.selectedJourneyId)
    }
    item.journeyId = this.selectedJourneyId
    item.note = this.note.trim()
    await SaituCheckInStore.saveCheckIn(item)
    await SaituAchievementStore.evaluateAndUnlock()
    SaituDetailNav.closeCheckInEditor()
    this.onSaved()
  }

  @Builder
  JourneyChip(j: Journey) {
    Text(j.name)
      .fontSize(Theme.type.bodyS)
      .fontColor(this.selectedJourneyId === j.id ? Theme.colors().brandOnPrimary : Theme.colors().textSecondary)
      .padding({ left: 12, right: 12, top: 8, bottom: 8 })
      .backgroundColor(this.selectedJourneyId === j.id ? j.color : Theme.colors().surfaceSubtle)
      .borderRadius(Theme.radius.pill)
      .onClick((): void => { this.selectedJourneyId = j.id })
  }

  build() {
    Stack({ alignContent: Alignment.Top }) {
      Column() {
        AppNavBar({
          title: this.existing !== undefined ? '今日打卡' : '赛途打卡',
          onBack: (): void => SaituDetailNav.closeCheckInEditor()
        })
        Scroll() {
          Column({ space: Theme.space.s4 }) {
            Text('选择今日推进的旅途')
              .fontSize(Theme.type.overline)
              .fontColor(Theme.colors().textTertiary)
            if (this.journeys.length === 0) {
              Text('还没有旅途，请先在赛途 Tab 创建。')
                .fontSize(Theme.type.bodyS)
                .fontColor(Theme.colors().textSecondary)
            } else {
              Flex({ wrap: FlexWrap.Wrap }) {
                ForEach(this.journeys, (j: Journey) => {
                  this.JourneyChip(j)
                }, (j: Journey) => j.id)
              }
            }
            TextArea({ text: this.note, placeholder: '可选：今日推进说明…' })
              .height(120)
              .fontSize(Theme.type.body)
              .backgroundColor(Theme.colors().surfaceSubtle)
              .borderRadius(Theme.radius.md)
              .onChange((v: string): void => { this.note = v })
            AppButton({
              label: this.existing !== undefined ? '更新打卡' : '完成打卡',
              variant: 'primary',
              onTap: (): void => { void this.save() }
            })
            Blank().height(Theme.space.s10)
          }
          .padding(Theme.space.pageX)
        }
        .layoutWeight(1)
      }
      .width('100%')
      .height('100%')
      .backgroundColor(Theme.colors().surfacePage)

      if (this.toastText.length > 0) {
        Text(this.toastText)
          .fontSize(Theme.type.bodyS)
          .fontColor(Theme.colors().textOnInverse)
          .padding({ left: 16, right: 16, top: 10, bottom: 10 })
          .backgroundColor(Theme.colors().surfaceInverse)
          .borderRadius(Theme.radius.pill)
          .margin({ top: Theme.space.s8 })
          .zIndex(20)
      }
    }
    .width('100%')
    .height('100%')
  }
}
