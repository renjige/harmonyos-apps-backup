import { Theme } from '../design-system/Theme'
import { AppNavBar } from '../design-system/AppNavBar'
import { AppButton } from '../design-system/AppButton'
import { InspirationItem } from '../../models/JournalModels'
import { TripStore } from '../../services/TripStore'
import { TripNav } from '../../services/TripNav'
import { AppToast } from '../../services/AppToast'

@Component
export struct InspireFormPane {
  @StorageLink('inspireFormId') @Watch('onId') formId: string = ''
  @StorageLink('darkModeOn') darkModeOn: boolean = false
  @Prop @Watch('onTok') refreshToken: number = 0
  @State title: string = ''
  @State body: string = ''
  @State destination: string = ''
  @State kind: string = 'destination'
  @State errorText: string = ''
  @State isEdit: boolean = false

  aboutToAppear(): void {
    this.hydrate()
  }

  onId(): void {
    this.hydrate()
  }

  onTok(): void {
    this.hydrate()
  }

  private hydrate(): void {
    this.errorText = ''
    this.isEdit = this.formId.length > 0
    if (!this.isEdit) {
      this.title = ''
      this.body = ''
      this.destination = ''
      this.kind = 'destination'
      return
    }
    const item = TripStore.findInspiration(this.formId)
    if (item === undefined) {
      this.errorText = '找不到这条灵感。'
      return
    }
    this.title = item.title
    this.body = item.body
    this.destination = item.destination
    this.kind = item.kind
  }

  private toggleKind(): void {
    this.kind = this.kind === 'destination' ? 'snippet' : 'destination'
  }

  private kindLabel(): string {
    return this.kind === 'snippet' ? '攻略片段' : '想去的目的地'
  }

  private async submit(): Promise<void> {
    if (this.title.trim().length === 0) {
      this.errorText = '请填写标题'
      return
    }
    const item = new InspirationItem()
    item.id = this.isEdit ? this.formId : TripStore.newInspirationId()
    item.title = this.title.trim()
    item.body = this.body.trim()
    item.destination = this.destination.trim()
    item.kind = this.kind
    item.updatedAt = Date.now()
    if (!this.isEdit) {
      item.createdAt = Date.now()
    } else {
      const old = TripStore.findInspiration(this.formId)
      item.createdAt = old !== undefined ? old.createdAt : Date.now()
    }
    await TripStore.saveInspiration(item)
    TripNav.closeInspireForm()
    AppToast.show(this.isEdit ? '灵感已更新' : '灵感已收藏')
  }

  build() {
    Column() {
      AppNavBar({
        title: this.isEdit ? '编辑灵感' : '添加灵感',
        onBack: (): void => { TripNav.closeInspireForm() }
      })
      if (this.errorText.length > 0) {
        Text(this.errorText)
          .fontSize(Theme.type.footnote)
          .fontColor(Theme.palette(this.darkModeOn).danger)
          .width('100%')
          .padding({ left: Theme.space.pageX, right: Theme.space.pageX, bottom: 8 })
      }
      Scroll() {
        Column({ space: Theme.space.s4 }) {
          Row() {
            Text('类型')
              .fontSize(Theme.type.subhead)
              .fontColor(Theme.palette(this.darkModeOn).textSecondary)
            Blank()
            Text(this.kindLabel())
              .fontSize(Theme.type.subhead)
              .fontColor(Theme.palette(this.darkModeOn).brandAccent)
              .onClick((): void => { this.toggleKind() })
          }
          .width('100%')
          TextInput({ text: this.title, placeholder: '标题' })
            .onChange((v: string) => { this.title = v })
          TextInput({ text: this.destination, placeholder: '目的地（选填）' })
            .onChange((v: string) => { this.destination = v })
          TextArea({ text: this.body, placeholder: '攻略片段、体验想法或备忘…' })
            .height(160)
            .onChange((v: string) => { this.body = v })
        }
        .width('100%')
        .padding({ left: Theme.space.pageX, right: Theme.space.pageX, bottom: Theme.space.s10 })
      }
      .layoutWeight(1)
      AppButton({
        label: this.isEdit ? '保存修改' : '保存灵感',
        onTap: (): void => { void this.submit() }
      })
        .margin({ left: Theme.space.pageX, right: Theme.space.pageX, bottom: Theme.space.s6 })
    }
    .width('100%')
    .height('100%')
    .backgroundColor(Theme.palette(this.darkModeOn).surfacePage)
  }
}
