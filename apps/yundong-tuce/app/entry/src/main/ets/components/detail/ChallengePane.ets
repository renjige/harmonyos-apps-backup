import { Theme } from '../design-system/Theme'
import { AppButton } from '../design-system/AppButton'
import { AppTextField } from '../design-system/AppTextField'
import { ChallengeItem } from '../../models/TuceModels'
import { TuceStore } from '../../services/TuceStore'
import { TuceEngine } from '../../services/TuceEngine'
import { TuceNav } from '../../services/TuceNav'

class ChallengeTpl {
  title: string = ''
  days: number = 7
}

@Component
export struct ChallengePane {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @StorageLink('tuceReload') @Watch('onReload') reloadToken: number = 0
  @State items: ChallengeItem[] = []
  @State customTitle: string = '我的挑战'
  @State customDays: string = '10'
  @State listEpoch: number = 0
  @State toastText: string = ''

  aboutToAppear(): void {
    void this.reload()
  }

  onReload(): void {
    void this.reload()
  }

  private showToast(msg: string): void {
    this.toastText = msg
    setTimeout((): void => { this.toastText = '' }, 2400)
  }

  private async reload(): Promise<void> {
    this.items = await TuceStore.challenges()
    this.listEpoch++
  }

  private templates(): ChallengeTpl[] {
    const out: ChallengeTpl[] = []
    const titles: string[] = ['7天活力挑战', '14天坚持挑战', '21天习惯挑战', '30天训练挑战']
    const days: number[] = [7, 14, 21, 30]
    for (let i = 0; i < titles.length; i++) {
      const t = new ChallengeTpl()
      t.title = titles[i]
      t.days = days[i]
      out.push(t)
    }
    return out
  }

  private async start(title: string, days: number): Promise<void> {
    if (days <= 0 || days > 365) {
      this.showToast('请输入 1–365 之间的天数')
      return
    }
    const c = new ChallengeItem()
    c.id = TuceStore.newId('ch')
    c.title = title
    c.days = days
    c.startDate = TuceStore.today()
    c.doneDates = ''
    await TuceStore.saveChallenge(c)
    await this.reload()
    TuceNav.bump()
    this.showToast('挑战已开启')
  }

  private doneCount(item: ChallengeItem): number {
    return TuceEngine.splitIdsSafe(item.doneDates).length
  }

  private async punch(itemId: string): Promise<void> {
    const list = await TuceStore.challenges()
    let target: ChallengeItem | undefined = undefined
    for (const it of list) {
      if (it.id === itemId) {
        target = it
      }
    }
    if (target === undefined) {
      return
    }
    const days = TuceEngine.splitIdsSafe(target.doneDates)
    const today = TuceStore.today()
    for (const d of days) {
      if (d === today) {
        this.showToast('今日已打卡')
        return
      }
    }
    days.push(today)
    target.doneDates = days.join('|')
    await TuceStore.saveChallenge(target)
    await TuceStore.addCheckin(today)
    await this.reload()
    TuceNav.bump()
    this.showToast('打卡成功')
  }

  build() {
    Stack() {
      Scroll() {
        Column({ space: Theme.space.s3 }) {
          Text('从模板开启，或自定义名称与天数。完成打卡会计入连续训练。')
            .fontSize(Theme.type.bodyS)
            .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
            .width('100%')
          ForEach(this.templates(), (t: ChallengeTpl) => {
            AppButton({
              label: `开启 ${t.title}`,
              variant: 'secondary',
              onTap: (): void => { void this.start(t.title, t.days) }
            })
          }, (t: ChallengeTpl) => t.title)

          Text('自定义挑战')
            .fontSize(Theme.type.subhead)
            .fontWeight(FontWeight.Medium)
            .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
            .width('100%')
          AppTextField({
            text: this.customTitle,
            placeholder: '挑战名称，如晨跑 10 天',
            onChange: (v: string): void => { this.customTitle = v }
          })
          AppTextField({
            text: this.customDays,
            placeholder: '挑战天数（1–365）',
            inputType: InputType.Number,
            onChange: (v: string): void => { this.customDays = v }
          })
          AppButton({
            label: '开启自定义挑战',
            variant: 'primary',
            onTap: (): void => {
              const days = parseInt(this.customDays, 10)
              const title = this.customTitle.trim().length > 0 ? this.customTitle.trim() : `自定义 ${days} 天`
              void this.start(title, days)
            }
          })

          Text('进行中的挑战')
            .fontSize(Theme.type.title3)
            .fontWeight(FontWeight.Bold)
            .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
            .width('100%')
          if (this.items.length === 0) {
            Text('还没有进行中的挑战，选上方模板或自定义开启')
              .fontSize(Theme.type.bodyS)
              .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
              .width('100%')
          }
          ForEach(this.items, (it: ChallengeItem) => {
            Column({ space: 6 }) {
              Text(it.title)
                .fontSize(Theme.type.body)
                .fontWeight(FontWeight.Medium)
                .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
                .width('100%')
              Text(`${this.doneCount(it)} / ${it.days} 天 · 自 ${it.startDate}`)
                .fontSize(Theme.type.caption)
                .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
                .width('100%')
              AppButton({
                label: '今日打卡',
                variant: 'primary',
                onTap: (): void => { void this.punch(it.id) }
              })
            }
            .width('100%')
            .padding(Theme.space.s4)
            .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
            .borderRadius(Theme.radius.md)
          }, (it: ChallengeItem) => `${it.id}_${this.doneCount(it)}_${this.listEpoch}`)
        }
        .padding({ left: Theme.space.pageX, right: Theme.space.pageX, bottom: Theme.space.s10 })
      }
      .width('100%')
      .height('100%')

      if (this.toastText.length > 0) {
        Text(this.toastText)
          .fontSize(Theme.type.footnote)
          .fontColor(Theme.colors().textOnInverse)
          .padding({ left: 16, right: 16, top: 10, bottom: 10 })
          .backgroundColor(Theme.colors().brandDeep)
          .borderRadius(Theme.radius.pill)
          .margin({ top: 12 })
          .zIndex(20)
      }
    }
    .width('100%')
    .height('100%')
    .alignContent(Alignment.Top)
  }
}
