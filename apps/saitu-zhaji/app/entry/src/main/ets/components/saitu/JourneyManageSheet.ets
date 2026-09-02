import { Theme } from '../design-system/Theme'
import { AppButton } from '../design-system/AppButton'
import { AppNavBar } from '../design-system/AppNavBar'
import { Journey } from '../../models/SaituModels'
import { SaituLocalStore } from '../../services/SaituLocalStore'
import { SaituDetailNav } from '../../services/SaituDetailNav'

@Component
export struct JourneyManageSheet {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @StorageLink('saituJourneyEpoch') @Watch('onJourneyEpochChange') journeyEpoch: number = 0
  onChanged: () => void = () => {}
  @State journeys: Journey[] = []
  @State nameInput: string = ''
  @State descInput: string = ''
  @State colorPick: string = '#007AFF'
  @State editingId: string = ''
  @State toastText: string = ''

  aboutToAppear(): void {
    void this.reload()
  }

  onJourneyEpochChange(): void {
    void this.reload()
  }

  private showToast(msg: string): void {
    this.toastText = msg
    setTimeout((): void => { this.toastText = '' }, 2600)
  }

  private async reload(): Promise<void> {
    const list = await SaituLocalStore.loadJourneys()
    const next: Journey[] = []
    for (const j of list) {
      next.push(j)
    }
    this.journeys = next
  }

  private resetForm(): void {
    this.nameInput = ''
    this.descInput = ''
    this.colorPick = '#007AFF'
    this.editingId = ''
  }

  private async saveJourney(): Promise<void> {
    const name = this.nameInput.trim()
    if (name.length === 0) {
      this.showToast('请填写旅途名称')
      return
    }
    let j: Journey
    if (this.editingId.length > 0) {
      const found = await SaituLocalStore.findJourney(this.editingId)
      if (found === undefined) {
        return
      }
      j = found
    } else {
      j = Journey.createNew(name)
    }
    j.name = name
    j.description = this.descInput.trim()
    j.color = this.colorPick
    await SaituLocalStore.saveJourney(j)
    this.resetForm()
    await this.reload()
    this.onChanged()
    this.showToast('旅途已保存')
  }

  private startEdit(j: Journey): void {
    this.editingId = j.id
    this.nameInput = j.name
    this.descInput = j.description
    this.colorPick = j.color
  }

  private async removeJourney(id: string): Promise<void> {
    await SaituLocalStore.deleteJourney(id)
    await this.reload()
    this.onChanged()
    this.showToast('旅途已删除')
  }

  build() {
    Stack({ alignContent: Alignment.Top }) {
      Column() {
        AppNavBar({
          title: '管理旅途',
          onBack: (): void => SaituDetailNav.closeJourneyManage()
        })
        Scroll() {
          Column({ space: Theme.space.s4 }) {
            TextInput({ text: this.nameInput, placeholder: '旅途名称' })
              .onChange((v: string): void => { this.nameInput = v })
            TextArea({ text: this.descInput, placeholder: '旅途说明（可选）' })
              .height(80)
              .onChange((v: string): void => { this.descInput = v })
            Row({ space: Theme.space.s2 }) {
              ForEach(Journey.presetColors(), (c: string) => {
                Column()
                  .width(32)
                  .height(32)
                  .backgroundColor(c)
                  .borderRadius(16)
                  .border({
                    width: this.colorPick === c ? 3 : 0,
                    color: Theme.colors().textPrimary
                  })
                  .onClick((): void => { this.colorPick = c })
              }, (c: string) => c)
            }
            AppButton({ label: this.editingId.length > 0 ? '更新旅途' : '新建旅途', variant: 'primary', onTap: (): void => { void this.saveJourney() } })

            ForEach(this.journeys, (j: Journey) => {
              Row({ space: Theme.space.s3 }) {
                Column()
                  .width(8)
                  .height(40)
                  .backgroundColor(j.color)
                  .borderRadius(4)
                Column({ space: 4 }) {
                  Text(j.name)
                    .fontSize(Theme.type.body)
                    .fontColor(Theme.colors().textPrimary)
                  if (j.description.length > 0) {
                    Text(j.description)
                      .fontSize(Theme.type.caption)
                      .fontColor(Theme.colors().textSecondary)
                      .maxLines(1)
                  }
                }
                .layoutWeight(1)
                .alignItems(HorizontalAlign.Start)
                Text('编辑')
                  .fontSize(Theme.type.bodyS)
                  .fontColor(Theme.colors().brandPrimary)
                  .onClick((): void => this.startEdit(j))
                Text('删除')
                  .fontSize(Theme.type.bodyS)
                  .fontColor(Theme.colors().danger)
                  .onClick((): void => { void this.removeJourney(j.id) })
              }
              .width('100%')
              .padding(Theme.space.cardPadding)
              .backgroundColor(Theme.colors().surfaceCard)
              .borderRadius(Theme.radius.lg)
            }, (j: Journey) => j.rowKey())

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
