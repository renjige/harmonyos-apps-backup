import { Theme } from '../design-system/Theme'
import { AppButton } from '../design-system/AppButton'
import { AppEmpty } from '../design-system/AppEmpty'
import { AppLoading } from '../design-system/AppLoading'
import { DetailShell } from '../detail/DetailShell'
import { RecordItem, StudyWriteRequest } from '../../models/RoadModels'
import { RoadBizService } from '../../services/RoadBizService'
import { RoadDetailNav } from '../../services/RoadDetailNav'
import { RoadMedia } from '../../services/RoadMedia'

@Component
export struct JournalFormPane {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop @Watch('onEditIdChange') editId: string = ''
  @Prop @Watch('onEditIdChange') refreshToken: number = 0
  @State title: string = ''
  @State placeLabel: string = ''
  @State body: string = ''
  @State toastText: string = ''
  @State saving: boolean = false

  aboutToAppear(): void {
    void this.hydrate()
  }

  onEditIdChange(): void {
    void this.hydrate()
  }

  private async hydrate(): Promise<void> {
    if (this.editId.length === 0) {
      return
    }
    const row = await RoadBizService.findJournal(this.editId)
    if (row !== undefined) {
      this.title = row.title
      this.placeLabel = row.placeLabel
      this.body = row.body
    }
  }

  private showToast(msg: string): void {
    this.toastText = msg
    setTimeout(() => { this.toastText = '' }, 2400)
  }

  private async save(): Promise<void> {
    if (this.title.trim().length < 2) {
      this.showToast('请填写手账标题')
      return
    }
    if (this.body.trim().length < 4) {
      this.showToast('请写下至少几句观察')
      return
    }
    this.saving = true
    const req = new StudyWriteRequest()
    req.title = this.title.trim()
    req.placeLabel = this.placeLabel.trim()
    req.body = this.body.trim()
    req.summary = this.body.trim()
    req.coverKey = 'empty_journal'
    if (this.editId.length > 0) {
      const ok = await RoadBizService.updateJournal(this.editId, req)
      this.saving = false
      this.showToast(ok ? '已更新' : '保存失败')
      if (ok) {
        setTimeout(() => { RoadDetailNav.close() }, 500)
      }
      return
    }
    const row = await RoadBizService.createJournal(req)
    this.saving = false
    if (row !== undefined) {
      this.showToast('手账已保存')
      setTimeout(() => { RoadDetailNav.close() }, 500)
      return
    }
    this.showToast('保存失败，请稍后重试')
  }

  build() {
    Stack({ alignContent: Alignment.Top }) {
      DetailShell({ title: this.editId.length > 0 ? '编辑手账' : '写研学手账', onClose: (): void => { RoadDetailNav.close() } }) {
        Column({ space: Theme.space.s4 }) {
          Image(RoadMedia.resource('empty_journal'))
            .width('100%')
            .height(140)
            .objectFit(ImageFit.Cover)
            .borderRadius(Theme.radius.md)
            .margin({ left: Theme.space.pageX, right: Theme.space.pageX })

          TextInput({ text: this.title, placeholder: '今天学到了什么' })
            .onChange((v: string) => { this.title = v })
            .height(48)
            .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
            .padding({ left: 12, right: 12 })
            .margin({ left: Theme.space.pageX, right: Theme.space.pageX })

          TextInput({ text: this.placeLabel, placeholder: '地点标记（手填，不使用定位）' })
            .onChange((v: string) => { this.placeLabel = v })
            .height(48)
            .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
            .padding({ left: 12, right: 12 })
            .margin({ left: Theme.space.pageX, right: Theme.space.pageX })

          TextArea({ text: this.body, placeholder: '把孩子的提问、你看到的一片叶子或一块砖写下来。仅保存在本应用内。' })
            .onChange((v: string) => { this.body = v })
            .height(180)
            .margin({ left: Theme.space.pageX, right: Theme.space.pageX })
            .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)

          AppButton({
            label: this.saving ? '保存中…' : '保存手账',
            onTap: (): void => { void this.save() }
          })
          .margin({ left: Theme.space.pageX, right: Theme.space.pageX, bottom: 16 })
        }
        .width('100%')
      }
      if (this.toastText.length > 0) {
        Text(this.toastText)
          .fontSize(Theme.type.subhead)
          .fontColor('#FFFFFF')
          .backgroundColor('rgba(20,61,40,0.92)')
          .padding({ left: 16, right: 16, top: 10, bottom: 10 })
          .borderRadius(Theme.radius.pill)
          .margin({ top: 12 })
      }
    }
    .width('100%')
    .height('100%')
  }
}
