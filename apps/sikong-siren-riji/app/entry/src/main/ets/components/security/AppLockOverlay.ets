import { Theme } from '../design-system/Theme'
import { AppButton } from '../design-system/AppButton'
import { AppLockService } from '../../services/AppLockService'

@Component
export struct AppLockOverlay {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @State pinInput: string = ''
  @State errorText: string = ''
  @Prop settingMode: boolean = false
  @State confirmPin: string = ''
  @State step: number = 1
  onUnlocked: () => void = () => {}
  onCancel: () => void = () => {}

  build() {
    Stack() {
      Column()
        .width('100%')
        .height('100%')
        .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfacePage : Theme.colors().surfacePage)

      Column({ space: Theme.space.s5 }) {
        Text(this.settingMode ? '设置应用锁' : '输入密码解锁')
          .fontSize(Theme.type.title2)
          .fontWeight(FontWeight.Bold)
          .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)

        Text(this.settingMode ?
          (this.step === 1 ? '请输入 4–6 位数字密码' : '请再次输入确认') :
          '私人日记已开启应用锁保护')
          .fontSize(Theme.type.body)
          .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)

        Row({ space: Theme.space.s3 }) {
          ForEach([0, 1, 2, 3, 4, 5], (i: number) => {
            Circle()
              .width(12)
              .height(12)
              .fill(i < this.pinInput.length ? Theme.colors().brandPrimary : Theme.colors().strokeStrong)
          }, (i: number) => `${i}`)
        }

        if (this.errorText.length > 0) {
          Text(this.errorText)
            .fontSize(Theme.type.caption)
            .fontColor(Theme.colors().danger)
        }

        this.NumPad()

        if (this.settingMode) {
          AppButton({ label: '取消', variant: 'secondary', onTap: (): void => this.onCancel() })
        }
      }
      .width('100%')
      .height('100%')
      .padding({ left: Theme.space.pageX, right: Theme.space.pageX, top: 80 })
    }
    .width('100%')
    .height('100%')
    .zIndex(90)
  }

  @Builder
  NumPad() {
    Column({ space: Theme.space.s3 }) {
      ForEach([[1, 2, 3], [4, 5, 6], [7, 8, 9], [-1, 0, -2]], (row: number[]) => {
        Row({ space: Theme.space.s4 }) {
          ForEach(row, (n: number) => {
            if (n === -1) {
              Text('')
                .width(72)
                .height(56)
            } else if (n === -2) {
              Text('删除')
                .width(72)
                .height(56)
                .textAlign(TextAlign.Center)
                .fontSize(Theme.type.body)
                .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
                .onClick((): void => this.backspace())
            } else {
              Text(`${n}`)
                .width(72)
                .height(56)
                .textAlign(TextAlign.Center)
                .fontSize(Theme.type.title3)
                .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
                .backgroundColor(Theme.colors().surfaceSubtle)
                .borderRadius(Theme.radius.md)
                .onClick((): void => this.appendDigit(`${n}`))
            }
          }, (n: number) => `${n}`)
        }
        .justifyContent(FlexAlign.Center)
      }, (row: number[]) => row.join('-'))
    }
    .width('100%')
  }

  private appendDigit(d: string): void {
    if (this.pinInput.length >= 6) {
      return
    }
    this.pinInput = `${this.pinInput}${d}`
    this.errorText = ''
    if (this.pinInput.length >= 4) {
      void this.trySubmit()
    }
  }

  private backspace(): void {
    if (this.pinInput.length === 0) {
      return
    }
    this.pinInput = this.pinInput.substring(0, this.pinInput.length - 1)
  }

  private async trySubmit(): Promise<void> {
    if (this.settingMode) {
      if (this.step === 1) {
        this.confirmPin = this.pinInput
        this.pinInput = ''
        this.step = 2
        return
      }
      if (this.pinInput !== this.confirmPin) {
        this.errorText = '两次输入不一致，请重试'
        this.pinInput = ''
        this.confirmPin = ''
        this.step = 1
        return
      }
      await AppLockService.setPin(this.pinInput)
      this.onUnlocked()
      return
    }
    const ok = await AppLockService.verifyPin(this.pinInput)
    if (ok) {
      this.onUnlocked()
    } else {
      this.errorText = '密码错误'
      this.pinInput = ''
    }
  }
}
