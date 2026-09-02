import { Theme } from '../design-system/Theme'
import { AppButton } from '../design-system/AppButton'
import { AppIcon } from '../design-system/AppIcon'
import { CreateInspirationRequest } from '../../models/InspirationModels'
import { InspirationBizService } from '../../services/InspirationBizService'
import { AuthService } from '../../services/AuthService'
import { GrowthService } from '../../services/GrowthService'

/** 对照精选写备忘：三问结构，不是空白笔记 */
@Component
export struct CompareWriteSheet {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @StorageLink('currentUsername') currentUsername: string = ''
  @Prop sourceTitle: string = ''
  @Prop sourceBody: string = ''
  @Prop sourceCoverKey: string = ''
  onClose: () => void = () => {}
  onSaved: () => void = () => {}
  onRequireAuth: () => void = () => {}
  @State qUse: string = ''
  @State qScene: string = ''
  @State qNext: string = ''
  @State saving: boolean = false
  @State formError: string = ''

  private async submit(): Promise<void> {
    if (!AuthService.requireAuth('create_inspiration')) {
      this.onRequireAuth()
      return
    }
    if (this.qUse.trim().length === 0 && this.qScene.trim().length === 0 && this.qNext.trim().length === 0) {
      this.formError = '至少回答一问，才能生成对照备忘'
      return
    }
    this.saving = true
    this.formError = ''
    const req = new CreateInspirationRequest()
    const shortTitle = this.sourceTitle.length > 12 ? this.sourceTitle.substring(0, 12) : this.sourceTitle
    req.title = `对照·${shortTitle}`
    req.body = `对照精选：《${this.sourceTitle}》\n原文要点：${this.sourceBody}\n\n可直接用：${this.qUse.trim()}\n可改到：${this.qScene.trim()}\n下一步：${this.qNext.trim()}`
    req.summary = req.body.length > 80 ? req.body.substring(0, 80) : req.body
    req.tags = ['对照', '精选']
    req.coverKey = this.sourceCoverKey.length > 0 ? this.sourceCoverKey : 'hero_latest_inspiration'
    req.userId = this.currentUsername
    const created = await InspirationBizService.createInspiration(req)
    this.saving = false
    if (created !== undefined) {
      await GrowthService.afterEventAuto(
        this.currentUsername, 'capture', created.title, 'inspiration', created.id
      )
      this.onSaved()
      this.onClose()
    } else {
      this.formError = InspirationBizService.lastError.length > 0
        ? InspirationBizService.lastError
        : '保存失败，请稍后重试'
    }
  }

  build() {
    Column() {
      Row({ space: Theme.space.s2 }) {
        Column() {
          AppIcon({ name: 'close', iconSize: Theme.icon.md })
        }
        .width(44)
        .height(44)
        .justifyContent(FlexAlign.Center)
        .onClick((): void => { this.onClose() })
        Text('对照写备忘')
          .fontSize(Theme.type.title3)
          .fontWeight(FontWeight.Medium)
          .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
          .layoutWeight(1)
      }
      .width('100%')
      .padding({ left: Theme.space.pageX - 8, right: Theme.space.pageX, top: Theme.space.s2 })

      Text(`对照《${this.sourceTitle}》，用三问写成可复用备忘，而不是再抄一遍原文。`)
        .fontSize(Theme.type.footnote)
        .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
        .width('100%')
        .padding({ left: Theme.space.pageX, right: Theme.space.pageX, bottom: Theme.space.s3 })

      if (this.formError.length > 0) {
        Text(this.formError)
          .fontSize(Theme.type.footnote)
          .fontColor(Theme.colors().danger)
          .width('100%')
          .padding({ left: Theme.space.pageX, right: Theme.space.pageX })
      }

      Scroll() {
        Column({ space: Theme.space.s4 }) {
          Column({ space: 6 }) {
            Text('哪一句可直接用？')
              .fontSize(Theme.type.caption)
              .fontColor(Theme.colors().textTertiary)
              .width('100%')
            TextArea({ text: this.qUse, placeholder: '摘一句可复用的节奏或画面…' })
              .width('100%')
              .height(88)
              .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
              .borderRadius(Theme.radius.sm)
              .onChange((v: string) => { this.qUse = v })
          }
          .width('100%')

          Column({ space: 6 }) {
            Text('可改到什么场景？')
              .fontSize(Theme.type.caption)
              .fontColor(Theme.colors().textTertiary)
              .width('100%')
            TextArea({ text: this.qScene, placeholder: '包装 / 界面 / 空间 / 文案标题…' })
              .width('100%')
              .height(88)
              .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
              .borderRadius(Theme.radius.sm)
              .onChange((v: string) => { this.qScene = v })
          }
          .width('100%')

          Column({ space: 6 }) {
            Text('下一步先做什么？')
              .fontSize(Theme.type.caption)
              .fontColor(Theme.colors().textTertiary)
              .width('100%')
            TextArea({ text: this.qNext, placeholder: '钉画板、改一版、做成计划…' })
              .width('100%')
              .height(88)
              .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
              .borderRadius(Theme.radius.sm)
              .onChange((v: string) => { this.qNext = v })
          }
          .width('100%')

          Column() {
            AppButton({
              label: this.saving ? '生成中…' : '生成对照备忘',
              disabled: this.saving,
              onTap: (): void => { void this.submit() }
            })
          }
          .width('100%')
          .onClick((): void => {
            if (!this.saving) {
              void this.submit()
            }
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
  }
}
