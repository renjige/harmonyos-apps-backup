import { Theme } from '../components/design-system/Theme'
import { AppHeader } from '../components/design-system/AppHeader'
import { AppButton } from '../components/design-system/AppButton'
import { CreateRecordRequest } from '../models/GrowthModels'
import { GrowthBizService } from '../services/GrowthBizService'
import { AuthService } from '../services/AuthService'

@Component
export struct RitualPage {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @StorageLink('currentUsername') currentUsername: string = ''
  onClose: () => void = () => {}
  onRequireAuth: () => void = () => {}
  onSaved: () => void = () => {}
  @State energy: string = '精力平稳'
  @State focus: string = ''
  @State note: string = ''
  @State errorText: string = ''
  @State submitting: boolean = false
  @State toastText: string = ''

  private energyOptions(): string[] {
    const list: string[] = []
    list.push('精力偏低')
    list.push('精力平稳')
    list.push('精力充沛')
    return list
  }

  private todayIso(): string {
    const d = new Date()
    const m = d.getMonth() + 1
    const day = d.getDate()
    const mm = m < 10 ? `0${m}` : `${m}`
    const dd = day < 10 ? `0${day}` : `${day}`
    return `${d.getFullYear()}-${mm}-${dd}`
  }

  private async submit(): Promise<void> {
    if (!AuthService.requireAuth('create_record')) {
      this.onRequireAuth()
      return
    }
    if (this.focus.trim().length === 0) {
      this.errorText = '请写下今天最重要的一件事'
      return
    }
    this.submitting = true
    this.errorText = ''
    const req = new CreateRecordRequest()
    const day = this.todayIso()
    req.title = `今日仪式 · ${day}`
    req.body = `精力：${this.energy}\n最重要的事：${this.focus.trim()}\n给自己的话：${this.note.trim()}`
    req.summary = this.focus.trim()
    const tags: string[] = []
    tags.push('今日仪式')
    req.tags = tags
    req.recordDate = day
    req.coverKey = 'hero_morning_coffee'
    req.userId = this.currentUsername
    const created = await GrowthBizService.createRecord(req)
    this.submitting = false
    if (created !== undefined) {
      this.onSaved()
      this.toastText = '今日仪式已写入成长记录'
      setTimeout(() => {
        this.toastText = ''
        this.onClose()
      }, 900)
    } else {
      this.errorText = '保存失败，请稍后重试'
    }
  }

  build() {
    Stack() {
      Column() {
        AppHeader({ title: '今日成长仪式', subtitle: '三问对齐今天再开始行动' })
        Scroll() {
          Column({ space: Theme.space.s4 }) {
            Text('1. 此刻精力如何？')
              .fontSize(Theme.type.subhead)
              .fontWeight(FontWeight.Medium)
              .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
              .width('100%')
            Flex({ wrap: FlexWrap.Wrap }) {
              ForEach(this.energyOptions(), (opt: string) => {
                Text(opt)
                  .fontSize(Theme.type.caption)
                  .fontColor(this.energy === opt ? Theme.colors().brandOnPrimary : Theme.colors().brandPrimary)
                  .padding({ left: 12, right: 12, top: 8, bottom: 8 })
                  .margin({ right: 8, bottom: 8 })
                  .backgroundColor(this.energy === opt ?
                    Theme.colors().brandPrimary : Theme.colors().brandPrimaryContainer)
                  .borderRadius(Theme.radius.pill)
                  .onClick((): void => { this.energy = opt })
              }, (opt: string) => opt)
            }
            .width('100%')

            Text('2. 今天最重要的一件事')
              .fontSize(Theme.type.subhead)
              .fontWeight(FontWeight.Medium)
              .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
              .width('100%')
            TextArea({ text: this.focus, placeholder: '只写一件，写得具体一点' })
              .width('100%')
              .height(88)
              .onChange((v: string) => { this.focus = v })

            Text('3. 给自己的一句话')
              .fontSize(Theme.type.subhead)
              .fontWeight(FontWeight.Medium)
              .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
              .width('100%')
            TextArea({ text: this.note, placeholder: '鼓励、提醒或边界都可以' })
              .width('100%')
              .height(72)
              .onChange((v: string) => { this.note = v })

            if (this.errorText.length > 0) {
              Text(this.errorText)
                .fontSize(Theme.type.footnote)
                .fontColor(Theme.colors().danger)
                .width('100%')
            }
            AppButton({
              label: this.submitting ? '保存中…' : '完成仪式并写入记录',
              onTap: (): void => { void this.submit() }
            })
            AppButton({
              label: '返回',
              variant: 'secondary',
              onTap: (): void => { this.onClose() }
            })
          }
          .padding({
            left: Theme.space.pageX,
            right: Theme.space.pageX,
            bottom: Theme.space.s10
          })
          .width('100%')
        }
        .layoutWeight(1)
        .scrollBar(BarState.Off)
      }
      .width('100%')
      .height('100%')
      .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfacePage : Theme.colors().surfacePage)

      if (this.toastText.length > 0) {
        Column() {
          Text(this.toastText)
            .fontSize(Theme.type.footnote)
            .fontColor(Theme.colors().brandOnPrimary)
            .padding({ left: 16, right: 16, top: 10, bottom: 10 })
            .backgroundColor(Theme.colors().brandPrimary)
            .borderRadius(Theme.radius.pill)
        }
        .width('100%')
        .padding({ top: Theme.space.s8 })
        .alignItems(HorizontalAlign.Center)
        .zIndex(30)
      }
    }
    .width('100%')
    .height('100%')
  }
}
