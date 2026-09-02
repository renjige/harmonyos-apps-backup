import { Theme } from '../components/design-system/Theme'
import { AppHeader } from '../components/design-system/AppHeader'
import { AppButton } from '../components/design-system/AppButton'
import { AppError } from '../components/design-system/AppError'
import { AppIcon } from '../components/design-system/AppIcon'
import { AuthService } from '../services/AuthService'
import { PrivacyService } from '../services/PrivacyService'
import { RegisterRequest } from '../models/ApiModels'
import { LegalDocKind, LegalDocOverlay } from '../components/legal/LegalDocOverlay'

@Component
export struct LoginPage {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop allowRegister: boolean = true
  @Prop allowSkip: boolean = false
  @State username: string = ''
  @State password: string = ''
  @State confirmPassword: string = ''
  @State realName: string = ''
  @State phone: string = ''
  @State inviteCode: string = ''
  @State loading: boolean = false
  @State isRegisterMode: boolean = false
  @State errorText: string = ''
  @State agreeLegal: boolean = false
  @State legalKind: LegalDocKind = 'privacy'
  @State showLegal: boolean = false
  onSuccess: () => void = () => {}
  onSkip: () => void = () => {}

  aboutToAppear(): void {
    this.agreeLegal = PrivacyService.isAccepted()
  }

  private isValidPhone(value: string): boolean {
    if (value.length !== 11) {
      return false
    }
    if (!value.startsWith('1')) {
      return false
    }
    for (let i = 0; i < value.length; i++) {
      const c = value.charAt(i)
      if (c < '0' || c > '9') {
        return false
      }
    }
    return true
  }

  private openLegal(kind: LegalDocKind): void {
    this.legalKind = kind
    this.showLegal = true
  }

  private async submit(): Promise<void> {
    if (this.loading) {
      return
    }
    if (!this.agreeLegal) {
      this.errorText = '请先阅读并同意《用户协议》和《隐私政策》'
      return
    }
    if (this.username.trim().length === 0) {
      this.errorText = '请输入账号'
      return
    }
    if (this.password.length === 0) {
      this.errorText = '请输入密码'
      return
    }
    if (this.isRegisterMode) {
      if (this.username.trim().length < 3) {
        this.errorText = '账号至少 3 位'
        return
      }
      if (this.password.length < 6) {
        this.errorText = '密码至少 6 位'
        return
      }
      if (this.confirmPassword !== this.password) {
        this.errorText = '两次输入的密码不一致'
        return
      }
      if (this.realName.trim().length === 0) {
        this.errorText = '请输入姓名'
        return
      }
      if (!this.isValidPhone(this.phone.trim())) {
        this.errorText = '请输入正确的手机号'
        return
      }
    }
    this.errorText = ''
    this.loading = true
    let ok = false
    try {
      if (this.isRegisterMode) {
        const body = new RegisterRequest()
        body.username = this.username.trim()
        body.password = this.password
        body.realName = this.realName.trim()
        body.phone = this.phone.trim()
        body.inviteCode = this.inviteCode.trim()
        ok = await AuthService.register(body)
      } else {
        ok = await AuthService.login(this.username.trim(), this.password)
      }
    } catch {
      ok = false
      AuthService.lastError = this.isRegisterMode ? '注册异常，请稍后重试' : '登录异常，请稍后重试'
    }
    this.loading = false
    if (ok) {
      await PrivacyService.acceptAndPersist()
      this.onSuccess()
    } else {
      if (AuthService.lastError.length > 0) {
        this.errorText = AuthService.lastError
      } else {
        this.errorText = this.isRegisterMode ? '注册失败，请检查信息或换一个账号' : '登录失败，请检查账号密码'
      }
    }
  }

  @Builder
  legalConsentRow() {
    Row({ space: Theme.space.s2 }) {
      Row() {
        if (this.agreeLegal) {
          AppIcon({
            name: 'check',
            iconSize: Theme.icon.sm,
            color: Theme.colors().brandOnPrimary
          })
        }
      }
      .width(22)
      .height(22)
      .justifyContent(FlexAlign.Center)
      .borderRadius(Theme.radius.xs)
      .backgroundColor(this.agreeLegal ? Theme.colors().brandPrimary : Theme.colors().surfaceCard)
      .border({
        width: 1,
        color: this.agreeLegal ? Theme.colors().brandPrimary : Theme.colors().strokeStrong
      })
      .onClick(() => {
        this.agreeLegal = !this.agreeLegal
        this.errorText = ''
      })

      Column({ space: 4 }) {
        Text('我已阅读并同意')
          .fontSize(Theme.type.footnote)
          .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
          .width('100%')
        Row({ space: 4 }) {
          Text('《用户协议》')
            .fontSize(Theme.type.footnote)
            .fontColor(this.themeEpoch >= 0 ? Theme.colors().brandPrimary : Theme.colors().brandPrimary)
            .onClick(() => this.openLegal('agreement'))
          Text('和')
            .fontSize(Theme.type.footnote)
            .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
          Text('《隐私政策》')
            .fontSize(Theme.type.footnote)
            .fontColor(this.themeEpoch >= 0 ? Theme.colors().brandPrimary : Theme.colors().brandPrimary)
            .onClick(() => this.openLegal('privacy'))
        }
        .width('100%')
      }
      .layoutWeight(1)
      .alignItems(HorizontalAlign.Start)
    }
    .width('100%')
    .alignItems(VerticalAlign.Top)
    .padding({ top: Theme.space.s1, bottom: Theme.space.s1 })
  }

  build() {
    Stack() {
      Scroll() {
        Column({ space: Theme.space.s4 }) {
          AppHeader({
            title: this.isRegisterMode ? '注册' : '登录',
            subtitle: '知错·错题智慧训练'
          })
          TextInput({ text: this.username, placeholder: this.isRegisterMode ? '账号（至少 3 位）' : '账号' })
            .height(48)
            .padding({ left: 12, right: 12 })
            .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
            .borderRadius(Theme.radius.sm)
            .onChange((value: string) => {
              this.username = value
            })
          TextInput({ text: this.password, placeholder: this.isRegisterMode ? '密码（至少 6 位）' : '密码' })
            .type(InputType.Password)
            .height(48)
            .padding({ left: 12, right: 12 })
            .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
            .borderRadius(Theme.radius.sm)
            .onChange((value: string) => {
              this.password = value
            })
          if (this.isRegisterMode) {
            if (this.username.trim().length > 0 && this.username.trim().length < 3) {
              Text('账号至少 3 个字符')
                .fontSize(Theme.type.caption)
                .fontColor(Theme.colors().danger)
            }
            TextInput({ text: this.confirmPassword, placeholder: '确认密码' })
              .type(InputType.Password)
              .height(48)
              .padding({ left: 12, right: 12 })
              .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
              .borderRadius(Theme.radius.sm)
              .onChange((value: string) => {
                this.confirmPassword = value
              })
            TextInput({ text: this.realName, placeholder: '姓名' })
              .height(48)
              .padding({ left: 12, right: 12 })
              .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
              .borderRadius(Theme.radius.sm)
              .onChange((value: string) => {
                this.realName = value
              })
            TextInput({ text: this.phone, placeholder: '手机号' })
              .type(InputType.PhoneNumber)
              .maxLength(11)
              .height(48)
              .padding({ left: 12, right: 12 })
              .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
              .borderRadius(Theme.radius.sm)
              .onChange((value: string) => {
                this.phone = value
              })
            TextInput({ text: this.inviteCode, placeholder: '邀请码（选填）' })
              .height(48)
              .padding({ left: 12, right: 12 })
              .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
              .borderRadius(Theme.radius.sm)
              .onChange((value: string) => {
                this.inviteCode = value
              })
          }
          this.legalConsentRow()
          if (this.errorText.length > 0) {
            AppError({ variant: 'inline', message: this.errorText })
          }
          AppButton({
            label: this.loading ? '请稍候…' : (this.isRegisterMode ? '注册并登录' : '登录'),
            disabled: this.loading,
            onTap: () => this.submit()
          })
          if (this.allowRegister) {
            AppButton({
              label: this.isRegisterMode ? '已有账号？去登录' : '没有账号？去注册',
              variant: 'ghost',
              onTap: () => {
                this.isRegisterMode = !this.isRegisterMode
                this.errorText = ''
              }
            })
          }
          if (this.allowSkip) {
            AppButton({
              label: '先逛逛',
              variant: 'secondary',
              onTap: () => this.onSkip()
            })
          }
        }
        .width('100%')
        .padding(Theme.space.pageX)
      }
      .width('100%')
      .height('100%')
      .scrollBar(BarState.Off)
      .align(Alignment.Center)
      .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfacePage : Theme.colors().surfacePage)

      if (this.showLegal) {
        LegalDocOverlay({
          kind: this.legalKind,
          onClose: () => {
            this.showLegal = false
          }
        })
          .width('100%')
          .height('100%')
      }
    }
    .width('100%')
    .height('100%')
  }
}
