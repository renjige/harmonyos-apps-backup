import { Theme } from '../design-system/Theme'
import { AppButton } from '../design-system/AppButton'
import { AppIcon } from '../design-system/AppIcon'
import { EssayItem } from '../../models/EssayModels'
import { EssayBizService } from '../../services/EssayBizService'
import { EssayNav } from '../../services/EssayNav'
import { EssaySmartTag } from '../../services/EssaySmartTag'
import { EssayStore } from '../../services/EssayStore'

@Component
export struct WriteEssayPane {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop editId: string = ''
  @Prop @Watch('onEditIdChange') refreshToken: number = 0
  onSaved: () => void = () => {}
  @State titleText: string = ''
  @State bodyText: string = ''
  @State tags: string[] = []
  @State customTag: string = ''
  @State weather: string = ''
  @State bodyAlign: string = 'start'
  @State tagChoices: string[] = []
  @State toastText: string = ''
  @State savedHint: string = '将自动保存'
  @State confirmLeave: boolean = false
  private editingId: string = ''
  private timerId: number = -1
  private dirty: boolean = false

  aboutToAppear(): void {
    this.hydrate()
    void this.loadRemote()
    this.timerId = setInterval((): void => {
      void this.autoSave()
    }, 5000)
  }

  aboutToDisappear(): void {
    if (this.timerId >= 0) {
      clearInterval(this.timerId)
      this.timerId = -1
    }
    void this.autoSave()
  }

  onEditIdChange(): void {
    this.hydrate()
  }

  private async loadRemote(): Promise<void> {
    const remote = await EssayBizService.loadTags()
    if (remote.length > 0) {
      this.tagChoices = remote
    }
    const pending = AppStorage.get<string>('pendingWeather') ?? ''
    if (pending.length > 0 && this.weather.length === 0) {
      this.weather = pending
      AppStorage.setOrCreate('pendingWeather', '')
      this.dirty = true
    }
  }

  private hydrate(): void {
    this.confirmLeave = false
    const found = this.editId.length > 0 ? EssayStore.find(this.editId) : undefined
    if (found !== undefined) {
      this.editingId = found.id
      this.titleText = found.title
      this.bodyText = found.content
      this.tags = found.tagList()
      this.weather = found.weather
      this.bodyAlign = found.align
      this.dirty = false
      return
    }
    this.editingId = ''
    this.titleText = ''
    this.bodyText = ''
    this.tags = []
    this.weather = ''
    this.bodyAlign = 'start'
    this.dirty = false
  }

  private showToast(msg: string): void {
    this.toastText = msg
    setTimeout(() => { this.toastText = '' }, 2200)
  }

  private wrap(mark: string): void {
    this.bodyText = `${this.bodyText}${mark}`
    this.dirty = true
  }

  private toggleTag(tag: string): void {
    const next: string[] = []
    let found = false
    for (const t of this.tags) {
      if (t === tag) {
        found = true
      } else {
        next.push(t)
      }
    }
    if (!found) {
      next.push(tag)
    }
    this.tags = next
    this.dirty = true
  }

  private addCustom(): void {
    const t = this.customTag.trim()
    if (t.length === 0) {
      return
    }
    this.toggleTag(t)
    this.customTag = ''
  }

  private async applyWeather(): Promise<void> {
    const daily = await EssayBizService.loadDaily(new Date().getHours())
    const title = EssayBizService.weatherTitle(daily)
    if (title.length > 0) {
      this.weather = title
      this.dirty = true
      this.showToast(`已写入「${this.weather}」`)
    }
  }

  private async autoSave(): Promise<void> {
    if (!this.dirty) {
      return
    }
    if (this.titleText.trim().length === 0 && this.bodyText.trim().length === 0) {
      return
    }
    await this.persist(false)
    this.savedHint = '已自动保存'
  }

  private async persist(closeAfter: boolean): Promise<void> {
    const suggested = EssaySmartTag.suggest(this.bodyText, this.titleText)
    const merged = EssaySmartTag.merge(this.tags, suggested)
    this.tags = merged
    let item: EssayItem
    if (this.editingId.length > 0) {
      const old = EssayStore.find(this.editingId)
      if (old !== undefined) {
        item = old
      } else {
        item = EssayStore.createDraft(this.titleText, this.bodyText, merged, this.weather, this.bodyAlign)
        this.editingId = item.id
      }
    } else {
      item = EssayStore.createDraft(this.titleText, this.bodyText, merged, this.weather, this.bodyAlign)
      this.editingId = item.id
    }
    item.title = this.titleText
    item.content = this.bodyText
    item.tagsCsv = EssaySmartTag.csv(merged)
    item.weather = this.weather
    item.align = this.bodyAlign
    await EssayStore.save(item)
    this.dirty = false
    this.onSaved()
    if (closeAfter) {
      EssayNav.closeWrite()
    }
  }

  private requestClose(): void {
    if (this.dirty) {
      this.confirmLeave = true
      return
    }
    EssayNav.closeWrite()
  }

  build() {
    Stack() {
      Column() {
        Row() {
          Column() {
            AppIcon({ name: 'chevron', iconSize: Theme.icon.md, color: Theme.colors().textPrimary })
          }
          .width(44)
          .height(44)
          .justifyContent(FlexAlign.Center)
          .rotate({ angle: 180 })
          .onClick((): void => { this.requestClose() })
          Text('新笺')
            .fontSize(Theme.type.title3)
            .fontWeight(FontWeight.Medium)
            .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
            .layoutWeight(1)
          Text(this.savedHint)
            .fontSize(Theme.type.caption)
            .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
        }
        .width('100%')
        .padding({ left: Theme.space.pageX - 8, right: Theme.space.pageX, top: 8 })

        Scroll() {
          Column({ space: Theme.space.s3 }) {
            TextInput({ text: this.titleText, placeholder: '给这篇随笔一个名字…' })
              .width('100%')
              .height(44)
              .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
              .fontSize(Theme.type.title3)
              .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
              .placeholderColor(Theme.colors().textTertiary)
              .onChange((v: string) => {
                this.titleText = v
                this.dirty = true
              })

            TextArea({ text: this.bodyText, placeholder: '写下此刻的心情…' })
              .width('100%')
              .height(280)
              .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
              .fontSize(Theme.type.body)
              .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
              .placeholderColor(Theme.colors().textTertiary)
              .textAlign(this.bodyAlign === 'center' ? TextAlign.Center : TextAlign.Start)
              .onChange((v: string) => {
                this.bodyText = v
                this.dirty = true
                this.savedHint = '正在书写…'
              })

            Row({ space: 8 }) {
              this.Fmt('加粗', (): void => { this.wrap('**') })
              this.Fmt('斜体', (): void => { this.wrap('*') })
              this.Fmt('标题', (): void => { this.wrap('# ') })
              this.Fmt(this.bodyAlign === 'center' ? '居左' : '居中', (): void => {
                this.bodyAlign = this.bodyAlign === 'center' ? 'start' : 'center'
                this.dirty = true
              })
            }
            .width('100%')

            Row({ space: 8 }) {
              AppButton({
                label: this.weather.length > 0 ? this.weather : '写入天色',
                variant: 'secondary',
                onTap: (): void => { void this.applyWeather() }
              })
              Text(`${this.bodyText.length} 字`)
                .fontSize(Theme.type.caption)
                .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
            }
            .width('100%')

            Text('🏷 标签')
              .fontSize(Theme.type.subhead)
              .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
              .width('100%')
            Flex({ wrap: FlexWrap.Wrap }) {
              ForEach(this.tagChoices, (tag: string) => {
                Text(tag)
                  .fontSize(Theme.type.caption)
                  .fontColor(this.tags.indexOf(tag) >= 0 ? Theme.colors().brandOnPrimary : Theme.colors().brandPrimary)
                  .padding({ left: 10, right: 10, top: 6, bottom: 6 })
                  .margin({ right: 8, bottom: 8 })
                  .backgroundColor(this.tags.indexOf(tag) >= 0 ?
                    Theme.colors().brandPrimary : Theme.colors().brandPrimaryContainer)
                  .borderRadius(Theme.radius.pill)
                  .onClick((): void => { this.toggleTag(tag) })
              }, (tag: string) => tag)
            }
            .width('100%')

            Row({ space: 8 }) {
              TextInput({ text: this.customTag, placeholder: '自定义标签' })
                .layoutWeight(1)
                .height(40)
                .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
                .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
                .onChange((v: string) => { this.customTag = v })
              AppButton({ label: '添加', variant: 'secondary', onTap: (): void => { this.addCustom() } })
            }
            .width('100%')

            AppButton({
              label: '完成',
              onTap: (): void => { void this.persist(true) }
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
        .edgeEffect(EdgeEffect.Spring)
      }
      .width('100%')
      .height('100%')
      .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfacePage : Theme.colors().surfacePage)

      if (this.toastText.length > 0) {
        Text(this.toastText)
          .fontSize(Theme.type.footnote)
          .fontColor(Theme.colors().textOnInverse)
          .padding({ left: 16, right: 16, top: 10, bottom: 10 })
          .backgroundColor(Theme.colors().brandDeep)
          .borderRadius(Theme.radius.pill)
          .margin({ top: 16 })
      }

      if (this.confirmLeave) {
        Column({ space: Theme.space.s3 }) {
          Text('尚未写完的字会自动保存。确定离开？')
            .fontSize(Theme.type.body)
            .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
            .width('100%')
          AppButton({
            label: '保存并离开',
            onTap: (): void => { void this.persist(true) }
          })
          AppButton({
            label: '继续写',
            variant: 'secondary',
            onTap: (): void => { this.confirmLeave = false }
          })
        }
        .width('86%')
        .padding(Theme.space.s5)
        .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
        .borderRadius(Theme.radius.lg)
      }
    }
    .width('100%')
    .height('100%')
    .alignContent(Alignment.Top)
  }

  @Builder
  Fmt(label: string, action: () => void) {
    Text(label)
      .fontSize(Theme.type.caption)
      .fontColor(this.themeEpoch >= 0 ? Theme.colors().brandPrimary : Theme.colors().brandPrimary)
      .padding({ left: 10, right: 10, top: 6, bottom: 6 })
      .backgroundColor(Theme.colors().brandPrimaryContainer)
      .borderRadius(Theme.radius.pill)
      .onClick(action)
  }
}
