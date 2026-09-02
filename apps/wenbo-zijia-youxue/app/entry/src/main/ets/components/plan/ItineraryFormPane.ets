import { Theme } from '../design-system/Theme'
import { AppButton } from '../design-system/AppButton'
import { AppDatePickerField } from '../design-system/AppDatePickerField'
import { DetailShell } from '../detail/DetailShell'
import { StudyWriteRequest } from '../../models/RoadModels'
import { RoadBizService } from '../../services/RoadBizService'
import { RoadDetailNav } from '../../services/RoadDetailNav'

@Component
export struct ItineraryFormPane {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop @Watch('onEditIdChange') editId: string = ''
  @Prop @Watch('onEditIdChange') refreshToken: number = 0
  @State title: string = ''
  @State startAt: string = ''
  @State endAt: string = ''
  @State itemsJson: string = ''
  @State remark: string = ''
  @State toastText: string = ''
  @State saving: boolean = false

  aboutToAppear(): void {
    void this.hydrate()
  }

  onEditIdChange(): void {
    void this.hydrate()
  }

  private async hydrate(): Promise<void> {
    const draft = AppStorage.get<string>('planDraftRouteId') ?? ''
    if (this.editId.length > 0) {
      const row = await RoadBizService.findItinerary(this.editId)
      if (row !== undefined) {
        this.title = row.title
        this.startAt = row.startAt
        this.endAt = row.endAt
        this.itemsJson = row.itemsJson
        this.remark = row.remark
      }
      return
    }
    if (draft.length > 0) {
      const route = await RoadBizService.findRoute(draft)
      if (route !== undefined) {
        this.title = `${route.title} · 家庭行程`
        this.remark = route.climateNote
      }
    }
  }

  private showToast(msg: string): void {
    this.toastText = msg
    setTimeout(() => { this.toastText = '' }, 2400)
  }

  private async save(): Promise<void> {
    if (this.title.trim().length < 2) {
      this.showToast('请填写行程名称')
      return
    }
    if (this.startAt.length === 0) {
      this.showToast('请选择出发日期')
      return
    }
    this.saving = true
    const body = new StudyWriteRequest()
    body.title = this.title.trim()
    body.startAt = this.startAt
    body.endAt = this.endAt
    body.itemsJson = this.itemsJson
    body.remark = this.remark
    body.routeId = AppStorage.get<string>('planDraftRouteId') ?? ''
    if (this.editId.length > 0) {
      const ok = await RoadBizService.updateItinerary(this.editId, body)
      this.saving = false
      this.showToast(ok ? '已更新' : '保存失败')
      if (ok) {
        setTimeout(() => { RoadDetailNav.close() }, 600)
      }
      return
    }
    const row = await RoadBizService.createItinerary(body)
    this.saving = false
    if (row !== undefined) {
      AppStorage.setOrCreate('planDraftRouteId', '')
      this.showToast('行程已保存')
      setTimeout(() => { RoadDetailNav.close() }, 600)
      return
    }
    this.showToast('保存失败，请稍后重试')
  }

  private async remove(): Promise<void> {
    if (this.editId.length === 0) {
      RoadDetailNav.close()
      return
    }
    const ok = await RoadBizService.deleteItinerary(this.editId)
    if (ok) {
      RoadDetailNav.close()
    }
  }

  build() {
    Stack({ alignContent: Alignment.Top }) {
      DetailShell({ title: this.editId.length > 0 ? '行程详情' : '新建行程', onClose: (): void => { RoadDetailNav.close() } }) {
        Column({ space: Theme.space.s4 }) {
          TextInput({ text: this.title, placeholder: '例如：莫干山三日课堂' })
            .onChange((v: string) => { this.title = v })
            .height(48)
            .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
            .padding({ left: 12, right: 12 })
            .margin({ left: Theme.space.pageX, right: Theme.space.pageX })

          Column() {
            AppDatePickerField({
              label: '出发日期',
              value: this.startAt,
              onChange: (v: string): void => { this.startAt = v }
            })
          }
          .width('100%')
          .padding({ left: Theme.space.pageX, right: Theme.space.pageX })

          Column() {
            AppDatePickerField({
              label: '返程日期',
              value: this.endAt,
              onChange: (v: string): void => { this.endAt = v }
            })
          }
          .width('100%')
          .padding({ left: Theme.space.pageX, right: Theme.space.pageX })

          Text('每日清单（景点 / 餐饮 / 住宿，一行一项）')
            .fontSize(Theme.type.caption)
            .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
            .padding({ left: Theme.space.pageX })
            .width('100%')

          TextArea({ text: this.itemsJson, placeholder: 'D1 上午 竹海栈道\nD1 午餐 山间食堂\nD1 住宿 林间民宿' })
            .onChange((v: string) => { this.itemsJson = v })
            .height(140)
            .margin({ left: Theme.space.pageX, right: Theme.space.pageX })
            .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)

          TextArea({ text: this.remark, placeholder: '气候备忘与家长备注' })
            .onChange((v: string) => { this.remark = v })
            .height(80)
            .margin({ left: Theme.space.pageX, right: Theme.space.pageX })
            .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)

          AppButton({
            label: this.saving ? '保存中…' : '保存行程',
            onTap: (): void => { void this.save() }
          })
          .margin({ left: Theme.space.pageX, right: Theme.space.pageX })

          if (this.editId.length > 0) {
            AppButton({
              label: '删除这条行程',
              variant: 'ghost',
              onTap: (): void => { void this.remove() }
            })
            .margin({ left: Theme.space.pageX, right: Theme.space.pageX })
          }
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
