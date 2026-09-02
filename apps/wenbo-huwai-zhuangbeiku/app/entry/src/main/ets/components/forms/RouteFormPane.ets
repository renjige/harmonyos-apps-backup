import { Theme } from '../design-system/Theme'
import { AppButton } from '../design-system/AppButton'
import { GearBizService } from '../../services/GearBizService'
import { GearDetailNav } from '../../services/GearDetailNav'
import { GearWriteRequest } from '../../models/GearModels'
import { DetailShell } from '../detail/DetailShell'

@Component
export struct RouteFormPane {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @State title: string = ''
  @State difficulty: string = '中级'
  @State distanceText: string = ''
  @State durationText: string = ''
  @State origin: string = ''
  @State dest: string = ''
  @State waypoints: string = ''
  @State errorText: string = ''
  @State saving: boolean = false
  private diffs: string[] = ['初级', '中级', '高级']

  private async save(): Promise<void> {
    if (this.title.trim().length === 0) {
      this.errorText = '请填写路线名称'
      return
    }
    const km = Number.parseFloat(this.distanceText)
    const hours = Number.parseFloat(this.durationText)
    if (Number.isNaN(km) || km <= 0) {
      this.errorText = '请填写距离（公里）'
      return
    }
    if (Number.isNaN(hours) || hours <= 0) {
      this.errorText = '请填写预计时长（小时）'
      return
    }
    this.saving = true
    const body = new GearWriteRequest()
    body.title = this.title.trim()
    body.difficulty = this.difficulty
    body.distanceKm = km
    body.durationH = hours
    body.origin = this.origin.trim()
    body.dest = this.dest.trim()
    body.waypoints = this.waypoints.trim()
    body.summary = `${this.difficulty} · ${km}km · ${hours}h`
    body.body = `自建路线。起 ${body.origin} 终 ${body.dest}。途经 ${body.waypoints}`
    body.coverKey = 'hero_ridge'
    const ok = await GearBizService.create('routes', body)
    this.saving = false
    if (ok) {
      GearDetailNav.close()
      return
    }
    this.errorText = '保存失败，请稍后重试'
  }

  build() {
    DetailShell({ title: '创建路线', onClose: () => GearDetailNav.close() }) {
      Column({ space: 12 }) {
        if (this.errorText.length > 0) {
          Text(this.errorText)
            .fontSize(Theme.type.footnote)
            .fontColor(Theme.colors().danger)
            .width('100%')
        }
        TextInput({ text: this.title, placeholder: '路线名称' })
          .onChange((v: string) => { this.title = v })
        Text('难度')
          .fontSize(Theme.type.caption)
          .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
          .width('100%')
        Flex({ wrap: FlexWrap.Wrap }) {
          ForEach(this.diffs, (c: string) => {
            Text(c)
              .fontSize(Theme.type.caption)
              .fontColor(this.difficulty === c ? Theme.colors().brandOnPrimary : Theme.colors().textPrimary)
              .padding({ left: 12, right: 12, top: 8, bottom: 8 })
              .margin({ right: 8, bottom: 8 })
              .backgroundColor(this.difficulty === c ? Theme.colors().brandPrimary : Theme.colors().surfaceSubtle)
              .borderRadius(Theme.radius.pill)
              .onClick(() => { this.difficulty = c })
          }, (c: string) => c)
        }
        TextInput({ text: this.distanceText, placeholder: '距离（公里）' })
          .type(InputType.Number)
          .onChange((v: string) => { this.distanceText = v })
        TextInput({ text: this.durationText, placeholder: '预计时长（小时）' })
          .type(InputType.Number)
          .onChange((v: string) => { this.durationText = v })
        TextInput({ text: this.origin, placeholder: '起点' })
          .onChange((v: string) => { this.origin = v })
        TextInput({ text: this.dest, placeholder: '终点' })
          .onChange((v: string) => { this.dest = v })
        TextInput({ text: this.waypoints, placeholder: '途经点（用顿号分隔）' })
          .onChange((v: string) => { this.waypoints = v })
        AppButton({
          label: this.saving ? '保存中…' : '保存路线',
          disabled: this.saving,
          onTap: (): void => { void this.save() }
        })
      }
      .padding({ left: Theme.space.pageX, right: Theme.space.pageX })
    }
  }
}
